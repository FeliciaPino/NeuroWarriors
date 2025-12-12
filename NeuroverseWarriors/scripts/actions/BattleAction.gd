extends Node
class_name BattleAction
#how the action is delivered to the target
enum ActionReach {MELEE,PROJECTILE,TELE,SELF}
#MELEE: User gets close to target.
#PROJECTILE: Projectile is thrown that gives effect
#TELE: Instant effect
#SELF: targets user only

#How the target is selected
enum ActionTargetSelection {PLAYER_CHOICE,RANDOM_ENEMY,RANDOM_ANY,AUTOCHAIN}
#PLAYER_CHOICE: the default, player chooses target
#RANDOM_ENEMY: random enemy is selected
#RANDOM_ANY: Any entity in the battlefield is chosen
#AUTOCHAIN: Player selects first target, rest is selected chaining.
var action_name
var verb #for example, punch, throw somethign at
var description
@export var reach:ActionReach
@export var isPositive:bool#wether or not it's something you'd want on your allies. healing is good, attacking is bad
@export var price:int #how much energy it takes to perform
@export var action_multiplier:float = 1 #value that multiplies the appropiate stat to decide the intencity of the action
@export var hits = 1 #This is only changed of actions that attack the same target multiple times (like pipes)
@export var target_count = 1 #how many targets can be chosen (mostly 1)
@export var charge_turns = 0 #How many turns does it take to finish (mostly alll of them are insta)
@export var accuracy = 1 #Chance each hit succeds.
@export var confusion = 0 #Chance the target is randomly changed
@export var body_part_source = "" #Hand_R, Hand_L, Eyes, etc
@export var effect_duration:int #how many turns the applied  status effect lasts
@export var effect_intensity:int #multiplier for the status effect
@export var projectile_speed:float = 100
var user:BattleEntity = null
var targets:Array[BattleEntity] = []
var current_target:BattleEntity
@export var animationType:String = "" #either  "attack", "throw", or "effect". Or another if it's unique maybe? 
@onready var sprite = $sprite
@onready var sounds:Array[AudioStreamPlayer]
@onready var animationPlayer:AnimationPlayer = $AnimationPlayer

signal action_impact_or_animation_changed
var did_impact := false
func set_did_impact_true():
	print("IIMPACTTTTT!!!!!!!!!!!!!")
	did_impact=true
signal action_finished


func _ready() -> void:
	sprite.visible = false
	for c in get_children():
		if c is AudioStreamPlayer:
			sounds.append(c)
func _random_sound():
	if sounds.size()<1:return
	sounds.pick_random().play()
func _do_action_effect():
	if not valid_targets() or not valid_user(): 
		print_debug(str(self,": somethings not valid"))
		return
	_action_effect()
	
func valid_targets()->bool:
	for target in targets:
		if target == null:
			return false
		if not is_instance_valid(target):
			return false
		if not target is BattleEntity:
			return false
		if not target.alive:
			return false
	return true
func valid_target()->bool:
	if current_target == null:
		return false
	if not is_instance_valid(current_target):
		return false
	if not current_target is BattleEntity:
		return false
	if not current_target.alive:
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
func execute(set_user:BattleEntity, set_targets:Array[BattleEntity]):
	user = set_user
	targets = set_targets
	user.action_impact.connect(action_impact_or_animation_changed.emit)
	user.action_impact.connect(set_did_impact_true)
	user.animation_player.animation_changed.connect(action_impact_or_animation_changed.emit)
	match reach:
		ActionReach.MELEE:
			for t in targets:
				current_target = t
				await _meele_action()
					
		ActionReach.PROJECTILE:
			for t in targets:
				for i in hits:
					current_target = t
					await _projectile_action()
		ActionReach.TELE, ActionReach.SELF:
			for t in targets:
				for i in hits:
					current_target = t
					await _ranged_non_projectile_action()
		_: #fallback
			pass
	
	user.action_impact.disconnect(action_impact_or_animation_changed.emit)
	user.action_impact.disconnect(set_did_impact_true)
	user.animation_player.animation_changed.disconnect(action_impact_or_animation_changed.emit)
	action_finished.emit()
#so, this does what the action does, be it increase stats, apply effects, or whatever. Each specific action will have to override it
func _action_effect()->void:
	pass
#does the walking thing and calls _action_effect
func _meele_action()->void:
	var spotToAttackFrom = current_target.global_position+Vector2(100 if current_target.global_position.x<user.global_position.x else -100, 0)
	if user==current_target:
		spotToAttackFrom = user.global_position
	user.walk_to(spotToAttackFrom,600)
	await user.finished_walking
	if not valid_user():
		print_debug("invalid user on action "+str(self))
		return
	if valid_target():
		if spotToAttackFrom.x < current_target.global_position.x: user.face_right()
		else: user.face_left()
		sprite.global_position = current_target.global_position
		current_target.got_on_your_personal_space(user)
	user.did_an_action(price)
	print_debug(str(self)+": approaching target")
	for i in hits:
		if !valid_user():break
		if !make_user_play_animation():
			if user.animation_player.has_animation("attack"): user.animation_player.play("attack")
		user.animation_player.seek(0)
		did_impact = false
		await action_impact_or_animation_changed
		await get_tree().process_frame
		if !valid_user():break
		var gotta_wait = did_impact
		_do_action_effect()
		if sounds[0].playing and sounds.size()>1:
			sounds[1].play()
		else:
			sounds[0].play()
		if gotta_wait:#wait until x% of the animation
			var target_time = user.animation_player.current_animation_length*0.99
			if i<hits-1:target_time *= 0.81
			while valid_user() and user.animation_player.current_animation_position < target_time:
				await  get_tree().process_frame
	
	if !valid_user():return
	user.walk_to(user.mySpot,500)
	await user.finished_walking
	user.settle_into_spot()

#does the throwing thing and calls _action_effect
func _projectile_action()->void:
	if not valid_user() or not valid_target(): return
	if current_target.global_position < user.global_position:
		user.face_left()
	else:
		user.face_right()
	if !make_user_play_animation():
		print_debug(user," doesn't have ",animationType)
		user.animation_player.play("throw")
		
	await action_impact_or_animation_changed
	sounds[0].play()
	if valid_target():
		sprite.rotation = (current_target.global_position-user.global_position).normalized().angle()
	sprite.visible = true
	if valid_user():
		user.did_an_action(price) #makes sense to charge when throwing the thing, even if it doesn't reach a target
		
		var anchor = null
		if body_part_source != "": anchor = user.visual_node.find_child(body_part_source)
		if anchor:
			sprite.global_position = anchor.global_position
		else:
			sprite.global_position = user.global_position
	animationPlayer.play("animation")
	var tween = get_tree().create_tween()
	if user != current_target:
		tween.tween_property(sprite,"global_position",current_target.global_position, sprite.global_position.distance_to(current_target.global_position)/(projectile_speed))
	else:
		print_debug("self projectile")
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
	
#plays the animation of the entity and calls _action_effect
func _ranged_non_projectile_action()->void:
	if not valid_user():
		return
	if !make_user_play_animation():
		user.animation_player.play("effect")
		
	print_debug(str(self,": wating for ",user," to finish animation ",user.animation_player.current_animation))
	await action_impact_or_animation_changed
	sounds[0].play()
	if valid_target():
		sprite.global_position = current_target.global_position
		animationPlayer.play("animation")
		_action_effect()
	if valid_user():
		user.did_an_action(price)
	
	action_finished.emit()
