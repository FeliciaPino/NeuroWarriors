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
@export var projectiles:Array[Node2D]
@export var animationType:String = "" #either  "attack", "throw", or "effect". Or another if it's unique maybe? 

@export var sound_variation_percentage:float
@export var _start_sfx:Array[AudioStreamPlayer] #sounds that play when action is started
@export var _impact_sfx:Array[AudioStreamPlayer] #sounds that play when action_impact is emitted
@export var _hit_sfx:Array[AudioStreamPlayer] #sounds that play when _action_effect is called (mostly for projectiles methinks)

@export var _user_start_vfx:Array[BattleVFX] #visual effects that play on the user when the action is started
@export var _user_impact_vfx:Array[BattleVFX] #eeh, you get the idea
@export var _user_hit_vfx:Array[BattleVFX]

@export var _target_start_vfx:Array[BattleVFX]
@export var _target_impact_vfx:Array[BattleVFX]
@export var _target_hit_vfx:Array[BattleVFX]

var user:BattleEntity = null

signal action_impact_or_animation_changed
var did_impact := false
func set_did_impact_true():
	did_impact=true
signal action_finished


func _ready() -> void:
	for vf in _user_start_vfx:
		vf.visible = false
		vf.process_mode = Node.PROCESS_MODE_DISABLED
	for vf in _user_hit_vfx:
		vf.visible = false
		vf.process_mode = Node.PROCESS_MODE_DISABLED
	for vf in _user_impact_vfx:
		vf.visible = false
		vf.process_mode = Node.PROCESS_MODE_DISABLED
		
	for vf in _target_start_vfx:
		vf.visible = false
		vf.process_mode = Node.PROCESS_MODE_DISABLED
	for vf in _target_impact_vfx:
		vf.visible = false
		vf.process_mode = Node.PROCESS_MODE_DISABLED
	for vf in _target_hit_vfx:
		vf.visible = false
		vf.process_mode = Node.PROCESS_MODE_DISABLED
	for p in projectiles:
		p.visible = false

func _do_action_effect(targets):
	if not valid_targets(targets) or not valid_user(): 
		print_debug(str(self,": somethings not valid"))
		return
	for t in targets:
		_action_effect(t)
func _play_vfx(entity:BattleEntity,vfx:Array[BattleVFX]):
	for vf in vfx:
		var new_vf = vf.duplicate()
		new_vf.visible = true
		new_vf.process_mode = Node.PROCESS_MODE_INHERIT
		entity.applied_vfx_node.add_child(new_vf)
func _play_rand_sfx(sfx:Array[AudioStreamPlayer]):
	if sfx.is_empty():return
	var sound:AudioStreamPlayer = sfx.pick_random().duplicate()
	add_child(sound)
	sound.pitch_scale = max(0.001,sound.pitch_scale + randf_range(-sound.pitch_scale*sound_variation_percentage,sound.pitch_scale*sound_variation_percentage))
	sound.play()
	sound.finished.connect(sound.queue_free)
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
	if !valid_user(): return
	_play_rand_sfx(_start_sfx)
	_play_vfx(user,_user_start_vfx)
	
	for t in targets:
		if !valid_target(t):continue
		_play_vfx(t,_target_start_vfx)
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
		if !valid_user():
			print_debug("invalid user on action "+str(self))
			return
		else:
			_play_vfx(user,_user_impact_vfx)
		if valid_target(current_target):
			if spotToAttackFrom.x < current_target.global_position.x: user.face_right()
			else: user.face_left()
			_play_vfx(current_target,_target_impact_vfx)
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
			_play_rand_sfx(_impact_sfx)
			await get_tree().process_frame
			if !valid_user():break
			if !valid_target(current_target):continue
			var gotta_wait = did_impact
			_action_effect(current_target)
			_play_rand_sfx(_hit_sfx)
			_play_vfx(current_target,_target_hit_vfx)
			_play_vfx(user,_user_hit_vfx)
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
	_play_rand_sfx(_impact_sfx)
	var projectile = projectiles.pick_random().duplicate()
	projectile.visible = true
	if valid_user():
		_play_vfx(user,_user_impact_vfx)
		user.did_an_action(price) #makes sense to charge when throwing the thing, even if it doesn't reach a target
		var anchor = null
		if body_part_source != "": anchor = user.visual_node.find_child(body_part_source)
		if anchor:
			projectile.global_position = anchor.global_position
		else:
			projectile.global_position = user.global_position
	if valid_target(target):
		_play_vfx(target,_target_impact_vfx)
		user.game_manager.vfx_node.add_child(projectile)
		projectile.rotation = (target.global_position-projectile.global_position).normalized().angle()
	var tween = get_tree().create_tween()
	if user != target:
		tween.tween_property(projectile,"global_position",target.global_position, projectile.global_position.distance_to(target.global_position)/(projectile_speed))
	else:
		print_debug("self projectile")
		tween.tween_property(projectile,"global_position",user.global_position+Vector2(0,-100),100.0/projectile_speed).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.tween_property(projectile,"global_position",user.global_position,100.0/projectile_speed).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.finished.connect(projectile_hit_target.bind(target,projectile))
	
func projectile_hit_target(target,projectile):
	projectile.visible = false
	if valid_target(target):
		_play_rand_sfx(_hit_sfx)
		_play_vfx(target,_target_hit_vfx)
		_action_effect(target)
	if valid_user():
		_play_vfx(user,_user_hit_vfx)
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
	_play_rand_sfx(_impact_sfx)
	_play_rand_sfx(_hit_sfx)
	for t in targets:
		if valid_target(t):
			_play_vfx(t,_target_impact_vfx)
			_play_vfx(t,_target_hit_vfx)
			_action_effect(t)
	if valid_user():
		user.did_an_action(price)
		_play_vfx(user,_user_impact_vfx)
		_play_vfx(user,_user_hit_vfx)
