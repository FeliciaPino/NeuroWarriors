extends BattleAction

func _ready():
	super._ready()
	action_multiplier = 2.75
	action_name = tr("BATTLE_ACTION_KATANA_SLASH_NAME")
	description = tr("BATTLE_ACTION_KATANA_SLASH_DESCRIPTION").format({multiplier=action_multiplier,stat=tr("BATTLESTAT_ATTACK")})
	verb = "attack"
	isMelee = true
	isPositive = false
	price = 4
	animationType = "throw"
	_validate_values_are_initialized()
func execute (user:BattleEntity, target:BattleEntity):
	super.execute(user,target)
	_meele_action()
func _action_effect()->void:
	target.receive_damage(user.attack*action_multiplier)
	
