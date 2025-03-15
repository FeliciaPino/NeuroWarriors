extends BattleAction

func _ready():
	super._ready()
	action_multiplier = 0.75
	action_name = tr("BATTLE_ACTION_PIPES_NAME")
	description = tr("BATTLE_ACTION_PIPES_DESCRIPTION").format({amount=3,multiplier=action_multiplier,stat=tr("BATTLESTAT_ATTACK")})
	verb = tr("BATTLE_ACTION_PIPES_VERB")
	isMelee = true
	isPositive = false
	price = 3
	animationType = "throw"
	_validate_values_are_initialized()

func execute (user:BattleEntity, target:BattleEntity):
	super.execute(user,target)
	_meele_action()
	
func _action_effect()->void:
	target.receive_damage(user.attack*action_multiplier)
