extends BattleAction

func _ready():
	super._ready()
	action_multiplier = 1.5
	action_name = tr("BATTLE_ACTION_ROBOT_PUNCH_NAME")
	description = tr("BATTLE_ACTION_ROBOT_PUNCH_DESCRIPTION").format({multiplier=action_multiplier,stat=tr("BATTLESTAT_ATTACK")})
	verb = tr("BATTLE_ACTION_ROBOT_PUNCH_VERB")
	isMelee = true
	isPositive = false
	price = 2
	animationType = "attack"
	_validate_values_are_initialized()
func execute (user:BattleEntity, target:BattleEntity):
	super.execute(user,target)
	_meele_action()
func _action_effect()->void:
	super._action_effect()
	target.receive_damage(user.attack*action_multiplier)
