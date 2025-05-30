extends BattleAction
var defense_effect = preload("res://scenes/status_effects/defense_up.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	effect_duration = 2
	action_name = tr("BATTLE_ACTION_FORCE_FIELD_NAME")
	description = tr("BATTLE_ACTION_FORCE_FIELD_DESCRIPTION").format({turn_amount=effect_duration})
	verb = tr("BATTLE_ACTION_FORCE_FIELD_VERB")
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
	effect.set_turns_remaining(effect_duration)
	effect.intensity = 10
	target.add_effect(effect)
