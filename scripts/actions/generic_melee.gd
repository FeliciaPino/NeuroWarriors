extends BattleAction

func _ready():
	super._ready()
	action_name = "Generic meele attack"
	description = "does melee damage"
	verb = "attack"
	isMelee = true
	isPositive = false
	price = 2
	animationType = "attack"
	_validate_values_are_initialized()

func execute (user:BattleEntity, target:BattleEntity):
	super.execute(user,target)
	_meele_action(user,target)
	
func _action_effect(user:BattleEntity, target:BattleEntity)->void:
	target.receive_damage(user.attack*2)
