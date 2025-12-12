extends BattleAction
# Called when the node enters the scene tree for the first time.
var poisoned_effect = preload("res://scenes/status_effects/poisoned.tscn")

func _ready() -> void:
	super._ready()
	action_name = tr("BATTLE_ACTION_POISON_DART_NAME")
	description = tr("BATTLE_ACTION_POISON_DART_DESCRIPTION").format({turn_amount=effect_duration,amount=5})
	verb = tr("BATTLE_ACTION_POSION_DART_VERB")

func _action_effect()->void:
	var effect:StatusEffect = poisoned_effect.instantiate()
	effect.turns_remaining = effect_duration
	effect.intensity = user.attack*effect_intensity
	current_target.add_effect(effect)
	current_target.receive_damage(int(user.attack*action_multiplier))
