extends BattleAction

var defense_effect = preload("res://scenes/status_effects/defense_up.tscn")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	action_name = tr("BATTLE_ACTION_TUTEL_SHIELD_NAME")
	description = tr("BATTLE_ACTION_TUTEL_SHIELD_DESCRIPTION").format({turn_amount=effect_duration})
	verb = tr("BATTLE_ACTION_TUTEL_SHIELD_VERB")
	isMelee = false
	isPositive = true
	price = 2
	animationType = "effect"
	_validate_values_are_initialized()
	

func execute (user:BattleEntity, target:BattleEntity):
	super.execute(user,target)
	_ranged_non_projectile_action()
func _action_effect()->void:
	var effect:StatusEffect = defense_effect.instantiate()
	effect.set_turns_remaining(3)
	effect.intensity = 15
	target.add_effect(effect)
