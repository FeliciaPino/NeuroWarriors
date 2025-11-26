extends BattleAction

func _ready():
	super._ready()
	action_multiplier = 1
	action_name = tr("BATTLE_ACTION_SCREECH_NAME")
	description = tr("BATTLE_ACTION_SCREECH_DESCRIPTION").format({multiplier=action_multiplier,stat=tr("BATTLESTAT_ATTACK")})
	verb = tr("BATTLE_ACTION_SCREECH_VERB")
	isMelee = false
	isPositive = false
	price = 4
	animationType = "effect"
	_validate_values_are_initialized()

func execute (user:BattleEntity, target:BattleEntity):
	super.execute(user,target)
	var projectile_speed = 600
	if not valid_user() or not valid_target(): return
	if target.global_position < user.global_position:
		user.face_left()
	else:
		user.face_right()
	user.animation_player.play(animationType)
	await get_tree().create_timer(0.4).timeout #for the animation to get to about the throwing part
	_random_sound()
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
		print_debug("self projectile")
		tween.tween_property(sprite,"global_position",user.global_position+Vector2(0,-100),100.0/projectile_speed).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.tween_property(sprite,"global_position",user.global_position,100.0/projectile_speed).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	await tween.finished
	#projectile got to target
	sprite.visible = false
	if valid_target():
		_action_effect()
	if valid_user():
		user.settle_into_spot()
		user.animation_player.play("idle")
	action_finished.emit()
	
const weakness_effect = preload("res://scenes/status_effects/sonic_weakness.tscn")
func _action_effect()->void:
	var effect:StatusEffect = weakness_effect.instantiate()
	effect.set_turns_remaining(2)
	effect.intensity = 6
	target.add_effect(effect)
	target.receive_damage(user.attack*action_multiplier)
