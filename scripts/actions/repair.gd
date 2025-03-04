extends BattleAction
# Called when the node enters the scene tree for the first time.

func _ready() -> void:
	super._ready()
	action_name = tr("BATTLE_ACTION_REPAIR_NAME")
	description = tr("BATTLE_ACTION_REPAIR_DESCRIPTION").format({amount=20})
	verb = tr("BATTLE_ACTION_REPAIR_VERB")
	isMelee = false
	isPositive = true
	price = 2
	animationType = "throw"
	_validate_values_are_initialized()

func execute (user:BattleEntity, target:BattleEntity):
	super.execute(user,target)
	_projectile_action(600)
	
func _action_effect()->void:
	target.heal(20)
