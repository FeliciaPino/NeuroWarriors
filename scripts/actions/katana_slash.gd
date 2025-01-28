extends BattleAction

func _ready():
	action_name = "Katana Slash"
	description = "Cool katana slash to obliterate you oponents"
	verb = "attack"
	isMelee = true
	isPositive = false
	price = 4
	animationType = "attack"
	_validate_values_are_initialized()
func execute (user:BattleEntity, target:BattleEntity):
	super.execute(user,target)
	_meele_action(user,target)
func _action_effect(user:BattleEntity, target:BattleEntity)->void:
	super._action_effect(user,target)
	target.receive_damage(user.attack*3.5)
	
