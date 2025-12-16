extends BattleAction

func _ready():
	super._ready()
	action_name = tr("BATTLE_ACTION_SCREECH_NAME")
	description = tr("BATTLE_ACTION_SCREECH_DESCRIPTION").format({multiplier=action_multiplier,stat=tr("BATTLESTAT_ATTACK")})
	verb = tr("BATTLE_ACTION_SCREECH_VERB")

	
const weakness_effect = preload("res://scenes/status_effects/sonic_weakness.tscn")
func _action_effect(target)->void:
	var effect:StatusEffect = weakness_effect.instantiate()
	effect.set_turns_remaining(effect_duration)
	effect.intensity = effect_intensity
	target.add_effect(effect)
	target.receive_damage(int(user.attack*action_multiplier))
