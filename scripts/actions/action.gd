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
@onready var sounds:Array[AudioStreamPlayer]
@onready var animationPlayer:AnimationPlayer = $AnimationPlayer
signal action_finished
func _ready() -> void:
	sprite.visible = false
	for c in get_children():
		if c is AudioStreamPlayer:
			sounds.append(c)
#gotta call this at the end of the sub-class initializer, to avoid me forgeting stuff. 
func _validate_values_are_initialized()->void:
	assert(action_name != null)
	assert(verb != null)
	assert(description != null)
	assert(isMelee != null)
	assert(isPositive != null) #I'm not sure if I should make this one obligatory. What if an action is neither good or bad? Eh, I'll cross that bridge then
	assert(price != null)
	assert(animationType != null)
	
#TODO: make user and target global variables, that way I can make a validate() function instead of doing is_instance_valid() all the time
	
#each specific action must override this with it's effects
func execute(user:BattleEntity, target:BattleEntity):
	if not user.alive: return
#so, this does what the action does, be it increase stats, apply effects, or whatever. Each specific action will have to override it
func _action_effect(user:BattleEntity, target:BattleEntity)->void:
	pass
#does the walking thing and calls _action_effect
func _meele_action(user:BattleEntity, target:BattleEntity)->void:
	var spotToAttackFrom = target.global_position+Vector2(100 if target.global_position.x<user.global_position.x else -100, 0)
	if user==target:
		spotToAttackFrom = user.global_position
	user.animation_player.play("walking")
	user.visual_node.scale = Vector2(-1,1) if target.global_position.x<user.global_position.x else Vector2(1,1)
	var tween = get_tree().create_tween()
	tween.tween_property(user,"global_position",spotToAttackFrom, user.global_position.distance_to(spotToAttackFrom)/500)
	await tween.finished
	#TODO: verify that the user hasn't been freed
	if is_instance_valid(target):
		target.got_on_your_personal_space(user)
	user.animation_player.play(animationType)
	animationPlayer.play("animation")
	sprite.global_position = target.global_position
	get_tree().create_timer(0.2).timeout.connect(func():sounds[0].play())
	await user.animation_player.animation_finished
	if is_instance_valid(target):
		_action_effect(user,target)
		user.did_an_action(price)
	user.animation_player.play("walking")
	user.visual_node.scale = Vector2(-1,1) if user.global_position.x > 550 else Vector2(1,1)
	tween = get_tree().create_tween()
	tween.tween_property(user,"global_position",user.mySpot,  user.global_position.distance_to(user.mySpot)/500)
	await tween.finished
	user.settle_into_spot()
	action_finished.emit()
	
#does the throwing thing and calls _action_effect
func _projectile_action(user:BattleEntity, target:BattleEntity, projectileSpeed=10)->void:
	user.animation_player.play(animationType)
	await  get_tree().create_timer(0.4).timeout #for the animation to get to about the throwing part
	sounds[0].play()
	if is_instance_valid(target):
		sprite.rotation = (target.global_position-user.global_position).normalized().angle()
	sprite.visible = true
	sprite.global_position = user.global_position
	animationPlayer.play("animation")
	var tween = get_tree().create_tween()
	tween.tween_property(sprite,"global_position",target.global_position, sprite.global_position.distance_to(target.global_position)/(projectileSpeed*40))
	await tween.finished
	sprite.visible = false
	if is_instance_valid(target):
		_action_effect(user,target)
		user.did_an_action(price)
		if sounds.size()>1:
			sounds[1].play()
	user.animation_player.play("idle")
	action_finished.emit()
#plays the animation of the entity and calls _action_effect
func _ranged_non_projectile_action(user:BattleEntity, target:BattleEntity)->void:
	user.animation_player.play(animationType)
	await user.animation_player.animation_finished
	sounds[0].play()
	animationPlayer.play("animation")
	animationPlayer.seek(0.0,true)
	sprite.play()
	if is_instance_valid(target):
		sprite.global_position = target.global_position
	sprite.visible = true
	await animationPlayer.animation_finished
	if is_instance_valid(target):
		_action_effect(user,target)
		user.did_an_action(price)
	await get_tree().create_timer(0.6).timeout
	sprite.visible = false
	user.animation_player.play("idle")
	action_finished.emit()

#deprecated
"""
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
"""
