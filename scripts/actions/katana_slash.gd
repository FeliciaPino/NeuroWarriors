extends BattleAction

func _ready():
	super._ready()
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
	_meele_action()
func _action_effect()->void:
	target.receive_damage(user.attack*2.5)
	
