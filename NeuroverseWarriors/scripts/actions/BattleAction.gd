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
@export var animationType:String = "" #either  "attack", "throw", or "effect". Or another if it's unique maybe? 
@onready var sprite = $sprite
@onready var sounds:Array[AudioStreamPlayer]
@onready var animationPlayer:AnimationPlayer = $AnimationPlayer

signal action_impact_or_animation_changed
var did_impact := false
func set_did_impact_true():
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
func _do_action_effect(targets):
	if not valid_targets(targets) or not valid_user(): 
		print_debug(str(self,": somethings not valid"))
		return
	for t in targets:
		_action_effect(t)
	
func valid_targets(targets:Array)->bool:
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
func valid_target(target)->bool:
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
func set_user(value:BattleEntity):
	if user:
		if user.action_impact.is_connected(action_impact_or_animation_changed.emit):
			user.action_impact.disconnect(action_impact_or_animation_changed.emit)
		if user.action_impact.is_connected(set_did_impact_true):
			user.action_impact.disconnect(set_did_impact_true)
		if user.animation_player.animation_changed.is_connected(action_impact_or_animation_changed.emit):
			user.animation_player.animation_changed.disconnect(action_impact_or_animation_changed.emit)
	user = value
	if ! user.action_impact.is_connected(action_impact_or_animation_changed.emit):
		user.action_impact.connect(action_impact_or_animation_changed.emit)
	if ! user.action_impact.is_connected(set_did_impact_true):
		user.action_impact.connect(set_did_impact_true)
	if ! user.animation_player.animation_changed.is_connected(action_impact_or_animation_changed.emit):
		user.animation_player.animation_changed.connect(action_impact_or_animation_changed.emit)
#each specific action must override this with it's effects
func execute(targets:Array[BattleEntity]):
	print_debug(action_name,"started")
	match reach:
		ActionReach.MELEE:
			await _meele_action(targets)
		ActionReach.PROJECTILE:
			for t in targets:
				for i in hits:
					await _projectile_action(t)
		ActionReach.TELE, ActionReach.SELF:
			for i in hits:
				await _ranged_non_projectile_action(targets)
		_: #fallback
			pass
	action_finished.emit()
#so, this does what the action does, be it increase stats, apply effects, or whatever. Each specific action will have to override it
func _action_effect(_target)->void:
	pass
#does the walking thing and calls _action_effect
func _meele_action(targets:Array)->void:
	for current_target in targets:
		var spotToAttackFrom = current_target.global_position+Vector2(100 if current_target.global_position.x<user.global_position.x else -100, 0)
		if user==current_target:
			spotToAttackFrom = user.global_position
		user.walk_to(spotToAttackFrom,600)
		await user.finished_walking
		if not valid_user():
			print_debug("invalid user on action "+str(self))
			return
		if valid_target(current_target):
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
			sprite.global_position = current_target.global_position
			animationPlayer.play("animation")
			_action_effect(current_target)
			if sounds[0].playing and sounds.size()>1:
				sounds[1].play()
			else:
				sounds[0].play()
			if gotta_wait:#wait until x% of the animation
				var target_time = user.animation_player.current_animation_length*0.99
				if i<hits-1:target_time *= 0.81
				await get_tree().create_timer(max(0,target_time  - user.animation_player.current_animation_position)).timeout
					
	
	if !valid_user():return
	user.walk_to(user.mySpot,500)
	await user.finished_walking
	user.settle_into_spot()

#does the throwing thing and calls _action_effect
func _projectile_action(target)->void:
	if not valid_user() or not valid_target(target): return
	if target.global_position < user.global_position:
		user.face_left()
	else:
		user.face_right()
	if !make_user_play_animation():
		print_debug(user," doesn't have ",animationType)
		user.animation_player.play("throw")
		
	await action_impact_or_animation_changed
	sounds[0].play()
	var new_sprite = sprite.duplicate()
	new_sprite.visible = true
	if valid_user():
		user.did_an_action(price) #makes sense to charge when throwing the thing, even if it doesn't reach a target
		var anchor = null
		if body_part_source != "": anchor = user.visual_node.find_child(body_part_source)
		if anchor:
			new_sprite.global_position = anchor.global_position
		else:
			new_sprite.global_position = user.global_position
	animationPlayer.play("animation")
	if valid_target(target):
		user.game_manager.vfx_node.add_child(new_sprite)
		new_sprite.rotation = (target.global_position-new_sprite.global_position).normalized().angle()
	var tween = get_tree().create_tween()
	if user != target:
		tween.tween_property(new_sprite,"global_position",target.global_position, new_sprite.global_position.distance_to(target.global_position)/(projectile_speed))
	else:
		print_debug("self projectile")
		tween.tween_property(new_sprite,"global_position",user.global_position+Vector2(0,-100),100.0/projectile_speed).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.tween_property(new_sprite,"global_position",user.global_position,100.0/projectile_speed).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.finished.connect(projectile_hit_target.bind(target,new_sprite))
	
func projectile_hit_target(target,projectile):
	projectile.visible = false
	if valid_target(target):
		_action_effect(target)
		if sounds.size()>1:
			sounds[1].play()
	if valid_user():
		user.settle_into_spot()
	projectile.queue_free()
#plays the animation of the entity and calls _action_effect
func _ranged_non_projectile_action(targets:Array)->void:
	if not valid_user():
		return
	if !make_user_play_animation():
		user.animation_player.play("effect")
		
	print_debug(str(self,": wating for ",user," to finish animation ",user.animation_player.current_animation))
	await action_impact_or_animation_changed
	sounds[0].play()
	for t in targets:
		if valid_target(t):
			sprite.global_position = t.global_position
			animationPlayer.play("animation")
			_action_effect(t)
	if valid_user():
		user.did_an_action(price)
	
