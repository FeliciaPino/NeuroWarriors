extends Node
class_name BattleAction
var action_name
var verb #for example, punch, throw somethign at
var description
var isMelee:bool
var isPositive:bool#wether or not it's something you'd want on your allies. healing is good, attacking is bad
var price:int #how much energy it takes to perform
var action_multiplier:float = 1 #value that multiplies the appropiate stat to decide the intencity of the action
var effect_duration:int = 2 #how many turns the applied effect lasts
var user:BattleEntity = null
var target:BattleEntity = null

var animationType:String #either  "attack", "throw", or "effect". Or another if it's unique maybe? 
@onready var sprite = $sprite
@onready var sounds:Array[AudioStreamPlayer]
@onready var animationPlayer:AnimationPlayer = $AnimationPlayer

signal action_effect
signal action_finished
func _ready() -> void:
	sprite.visible = false
	for c in get_children():
		if c is AudioStreamPlayer:
			sounds.append(c)
	action_effect.connect(_do_action_effect)
func _random_sound():
	if sounds.size()<1:return
	sounds.pick_random().play()
func _do_action_effect():
	if not valid_target() or not valid_user(): 
		print(str(self,": somethings not valid"))
		return
	_action_effect()
#gotta call this at the end of the sub-class initializer, to avoid me forgeting stuff. 
func _validate_values_are_initialized()->void:
	assert(action_name != null)
	assert(verb != null)
	assert(description != null)
	assert(isMelee != null)
	assert(isPositive != null) #I'm not sure if I should make this one obligatory. What if an action is neither good or bad? Eh, I'll cross that bridge then
	assert(price != null)
	assert(animationType != null)
	
func valid_target()->bool:
	if target == null:
		return false
	if not is_instance_valid(target):
		return false
	if not target is BattleEntity:
		return false
	if not target.alive:
		return false
	return true
func valid_user()->bool:
	if user == null:
		return false
	if not is_instance_valid(user):
		return false
	if not user is BattleEntity:
		return false
	if not user.alive:
		return false
	return true
	
func make_user_play_animation() -> bool:
	if not valid_user(): return false
	if user.animation_player.has_animation(animationType):
		user.animation_player.play(animationType)
		return true
	else:
		return false

#each specific action must override this with it's effects
func execute(user:BattleEntity, target:BattleEntity):
	self.user = user
	self.target = target
#so, this does what the action does, be it increase stats, apply effects, or whatever. Each specific action will have to override it
func _action_effect()->void:
	pass
#does the walking thing and calls _action_effect
func _meele_action()->void:
	var spotToAttackFrom = target.global_position+Vector2(100 if target.global_position.x<user.global_position.x else -100, 0)
	if user==target:
		spotToAttackFrom = user.global_position
	user.walk_to(spotToAttackFrom,500)
	await user.finished_walking
	print(str(self)+": approaching target")
	if not valid_user():
		print("invalid user on action "+str(self))
		action_finished.emit()
		return
	if valid_target():
		if spotToAttackFrom.x < target.global_position.x: user.face_right()
		else: user.face_left()
		sprite.global_position = target.global_position
		target.got_on_your_personal_space(user)
	
	animationPlayer.play("animation") #the animation calls the effect and makes the sounds
	user.animation_player.play(animationType)
	user.did_an_action(price)
	print(str(self)+": waiting for action effect to finish")
	await animationPlayer.animation_finished
	user.walk_to(user.mySpot,500)
	await user.finished_walking
	
	user.settle_into_spot()
	action_finished.emit()

#does the throwing thing and calls _action_effect
func _projectile_action(projectile_speed:float=10)->void:
	if not valid_user() or not valid_target(): return
	if target.global_position < user.global_position:
		user.face_left()
	else:
		user.face_right()
	user.animation_player.play(animationType)
	await get_tree().create_timer(0.4).timeout #for the animation to get to about the throwing part
	sounds[0].play()
	if valid_target():
		sprite.rotation = (target.global_position-user.global_position).normalized().angle()
	sprite.visible = true
	if valid_user():
		user.did_an_action(price) #makes sense to charge when throwing the thing, even if it doesn't reach a target
		sprite.global_position = user.global_position
	animationPlayer.play("animation")
	var tween = get_tree().create_tween()
	if user != target:
		tween.tween_property(sprite,"global_position",target.global_position, sprite.global_position.distance_to(target.global_position)/(projectile_speed))
	else:
		print("self projectile")
		tween.tween_property(sprite,"global_position",user.global_position+Vector2(0,-100),100.0/projectile_speed).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.tween_property(sprite,"global_position",user.global_position,100.0/projectile_speed).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	await tween.finished
	#projectile got to target
	sprite.visible = false
	if valid_target():
		_action_effect()
		if sounds.size()>1:
			sounds[1].play()
	if valid_user():
		user.settle_into_spot()
		user.animation_player.play("idle")
	action_finished.emit()
#plays the animation of the entity and calls _action_effect
func _ranged_non_projectile_action()->void:
	if not valid_user():
		return
	user.animation_player.play(animationType)
	print(str(self,": wating for ",user," to finish animation ",user.animation_player.current_animation))
	await user.animation_player.animation_changed #sometimes is not
	print(str(user)+"finished animation")
	sounds[0].play()
	#the animation instructs the action effect
	animationPlayer.play("animation")
	animationPlayer.seek(0.0,true)
	if valid_target():
		sprite.global_position = target.global_position
	if valid_user():
		user.did_an_action(price)
	await animationPlayer.animation_finished
	user.animation_player.play("idle")
	action_finished.emit()
