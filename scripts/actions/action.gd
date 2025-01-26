extends Node
class_name BattleAction
var action_name
var verb #for example, punch, throw somethign at
var description
var isMelee:bool
var isPositive:bool#wether or not it's something you'd want on your allies. healing is good, attacking is bad
var price:int #how much energy it takes to perform

var animationType:String #either  "attack", "throw", or "effect". Or another if it's unique maybe? 
@onready var sprite = $sprite
@onready var sound:AudioStreamPlayer = $sound
@onready var animationPlayer:AnimationPlayer = $AnimationPlayer
signal action_finished
func _ready() -> void:
	sprite.visible = false
#gotta call this at the end of the sub-class initializer, to avoid me forgeting stuff. 
func _validate_values_are_initialized()->void:
	assert(action_name != null)
	assert(verb != null)
	assert(description != null)
	assert(isMelee != null)
	assert(isPositive != null) #I'm not sure if I should make this one obligatory. What if an action is neither good or bad? Eh, I'll cross that bridge then
	assert(price != null)
	assert(animationType != null)
	
#each specific action must override this with it's effects
func execute(user:BattleEntity, target:BattleEntity):
	if not user.alive: return
	#I don't think this should be here in this part, it should be when the character is already standing by the target
	if isMelee:
		target.got_on_your_personal_space(user)
	user.did_an_action(price)
#so, this does what the action does, be it increase stats, apply effects, or whatever. Each specific action will have to override it
func _action_effect(user:BattleEntity, target:BattleEntity)->void:
	pass
#does the walking thing and calls _action_effect
func _meele_action(user:BattleEntity, target:BattleEntity)->void:
	var spotToAttackFrom = target.global_position+Vector2(100 if target.global_position.x<user.global_position.x else -100, 0)
	if user==target:
		spotToAttackFrom = user.global_position
	user.animated_sprite.play("run")
	var tween = get_tree().create_tween()
	tween.tween_property(user,"global_position",spotToAttackFrom, 1)
	await tween.finished
	target.got_on_your_personal_space(user)
	user.animation_player.play(animationType)
	await user.animation_player.animation_finished
	if target:
		_action_effect(user,target)
	user.animated_sprite.play("run")
	user.animated_sprite.flip_h = user.global_position.x > 550
	tween = get_tree().create_tween()
	tween.tween_property(user,"global_position",user.mySpot, 1)
	await tween.finished
	user.settle_into_spot()
	action_finished.emit()
	
#does the throwing thing and calls _action_effect
func _projectile_action(user:BattleEntity, target:BattleEntity, projectileSpeed=10)->void:
	user.animation_player.play(animationType)
	await  get_tree().create_timer(0.6).timeout #for the animation to get to about the throwing part
	sound.play()
	sprite.rotation = (target.global_position-user.global_position).normalized().angle()
	sprite.visible = true
	sprite.global_position = user.global_position
	animationPlayer.play("animation")
	var tween = get_tree().create_tween()
	tween.tween_property(sprite,"global_position",target.global_position, 10.0/projectileSpeed)
	await tween.finished
	sprite.visible = false
	_action_effect(user,target)
	action_finished.emit()
#plays the animation of the entity and calls _action_effect
func _ranged_non_projectile_action(user:BattleEntity, target:BattleEntity)->void:
	user.animation_player.play(animationType)
	await user.animation_player.animation_finished
	sound.play()
	animationPlayer.play("animation")
	sprite.play()
	sprite.global_position = target.global_position
	sprite.visible = true
	await animationPlayer.animation_finished
	_action_effect(user,target)
	await get_tree().create_timer(0.6).timeout
	sprite.visible = false
	action_finished.emit()

#deprecated
func projectile(source:Node, bullet:Node2D, target:Node, speed):
	bullet.visible = true
	bullet.global_position = source.global_position
	var tween = get_tree().create_tween()
	tween.tween_property(bullet, "global_position", target.global_position, 1.0/speed)
	tween.finished.connect(func():bullet.visible=false)
	
func walk_to(user:BattleEntity, target:Vector2):
	var tween = get_tree().create_tween()
	tween.tween_property(user, "global_position", target, 0.4)
	await tween.finished
