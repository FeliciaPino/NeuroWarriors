extends BattleAction

func _ready():
	super._ready()
	action_name = tr("BATTLE_ACTION_GENERIC_MELEE_NAME")
	description = tr("BATTLE_ACTION_GENERIC_MELEE_DESCRIPTION")
	verb = tr("BATTLE_ACTION_GENERIC_MELEE_VERB")
	isMelee = true
	isPositive = false
	price = 2
	animationType = "attack"
	_validate_values_are_initialized()

func execute (user:BattleEntity, target:BattleEntity):
	super.execute(user,target)
	_meele_action()
	
func _action_effect()->void:
	target.receive_damage(user.attack*2)
