extends BattleAction
var shocked_effect = preload("res://scenes/status_effects/shocked.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	action_multiplier = 2
	action_name = tr("BATTLE_ACTION_SHOCK_NAME")
	description = tr("BATTLE_ACTION_SHOCK_DESCRIPTION").format({multiplier=action_multiplier,stat=tr("BATTLESTAT_ATTACK"),turn_amount=effect_duration})
	verb = tr("BATTLE_ACTION_SHOCK_VERB")
	isMelee = false
	isPositive = false
	price = 4
	animationType = "effect"
	_validate_values_are_initialized()

func execute (user:BattleEntity, target:BattleEntity):
	super.execute(user,target)
	_ranged_non_projectile_action()
func _action_effect()->void:
	var effect:StatusEffect = shocked_effect.instantiate()
	effect.set_turns_remaining(2)
	target.add_effect(effect)
	target.receive_damage(user.attack*action_multiplier)
