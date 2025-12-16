extends BattleAction

var defense_effect = preload("res://scenes/status_effects/defense_up.tscn")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	action_name = tr("BATTLE_ACTION_TUTEL_SHIELD_NAME")
	description = tr("BATTLE_ACTION_TUTEL_SHIELD_DESCRIPTION").format({turn_amount=effect_duration})
	verb = tr("BATTLE_ACTION_TUTEL_SHIELD_VERB")
	

func _action_effect(target)->void:
	var effect:StatusEffect = defense_effect.instantiate()
	effect.set_turns_remaining(effect_duration)
	effect.intensity = effect_intensity
	target.add_effect(effect)
