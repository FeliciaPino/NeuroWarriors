extends BattleAction
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	action_name = tr("BATTLE_ACTION_OVERCLOCK_NAME")
	description = tr("BATTLE_ACTION_OVERCLOCK_DESCRIPTION").format({stat=tr("BATTLESTAT_AP_REGEN")})
	verb = tr("BATTLE_ACTION_OVERCLOCK_VERB")
	

const overclocked_effect = preload("res://scenes/status_effects/overclocked.tscn")
func _action_effect()->void:
	var effect:StatusEffect = overclocked_effect.instantiate()
	effect.turns_remaining = effect_duration
	effect.intensity = effect_intensity
	current_target.add_effect(effect)
