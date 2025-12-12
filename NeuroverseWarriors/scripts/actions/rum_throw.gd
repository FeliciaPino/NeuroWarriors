extends BattleAction
# Called when the node enters the scene tree for the first time.
var poisoned_effect = preload("res://scenes/status_effects/poisoned.tscn")

func _ready() -> void:
	super._ready()
	action_name = tr("BATTLE_ACTION_RUM_THROW_NAME")
	description = tr("BATTLE_ACTION_RUM_THROW_DESCRIPTION").format({multiplier=action_multiplier,stat=tr("BATTLESTAT_ATTACK"), turn_amount=effect_duration})
	verb = tr("BATTLE_ACTION_RUM_THROW_VERB")

func _action_effect()->void:
	var effect:StatusEffect = poisoned_effect.instantiate()
	effect.intensity = effect_intensity
	effect.turns_remaining = effect_duration
	current_target.add_effect(effect)
	if current_target.entity_name == "Vedal":
		current_target.heal(20)
		return
	current_target.receive_damage(int(user.attack*action_multiplier))
