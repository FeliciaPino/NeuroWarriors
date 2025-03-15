extends BattleAction

func _ready():
	super._ready()
	action_multiplier = 1
	action_name = tr("BATTLE_ACTION_SCREECH_NAME")
	description = tr("BATTLE_ACTION_SCREECH_DESCRIPTION").format({multiplier=action_multiplier,stat=tr("BATTLESTAT_ATTACK")})
	verb = tr("BATTLE_ACTION_SCREECH_VERB")
	isMelee = false
	isPositive = false
	price = 4
	animationType = "effect"
	_validate_values_are_initialized()

func execute (user:BattleEntity, target:BattleEntity):
	super.execute(user,target)
	_projectile_action(600)
	
const weakness_effect = preload("res://scenes/status_effects/sonic_weakness.tscn")
func _action_effect()->void:
	var effect:StatusEffect = weakness_effect.instantiate()
	effect.set_turns_remaining(2)
	effect.intensity = 6
	target.add_effect(effect)
	target.receive_damage(user.attack*action_multiplier)
