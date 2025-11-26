extends BattleAction

var attack_effect = preload("res://scenes/status_effects/attack_up.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	effect_duration = 2
	action_name = tr("BATTLE_ACTION_INCREASE_ATTACK_NAME")
	description = tr("BATTLE_ACTION_INCREASE_ATTACK_DESCRIPTION").format({turn_amount=effect_duration})
	verb = tr("BATTLE_ACTION_INCREASE_ATTACK_VERB")
	isMelee = false
	isPositive = true
	price = 2
	animationType = "effect"
	_validate_values_are_initialized()
	

func execute (user:BattleEntity, target:BattleEntity):
	super.execute(user,target)
	_ranged_non_projectile_action()
func _action_effect()->void:
	var effect:StatusEffect = attack_effect.instantiate()
	effect.set_turns_remaining(effect_duration)
	effect.intensity = 10
	target.add_effect(effect)
