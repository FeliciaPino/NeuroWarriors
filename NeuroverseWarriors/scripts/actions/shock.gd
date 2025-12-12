extends BattleAction
var shocked_effect = preload("res://scenes/status_effects/shocked.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	action_name = tr("BATTLE_ACTION_SHOCK_NAME")
	description = tr("BATTLE_ACTION_SHOCK_DESCRIPTION").format({multiplier=action_multiplier,stat=tr("BATTLESTAT_ATTACK"),turn_amount=effect_duration})
	verb = tr("BATTLE_ACTION_SHOCK_VERB")

func _action_effect()->void:
	var effect:StatusEffect = shocked_effect.instantiate()
	effect.set_turns_remaining(effect_duration)
	effect.intensity = effect_intensity
	current_target.add_effect(effect)
	current_target.receive_damage(int(user.attack*action_multiplier))
