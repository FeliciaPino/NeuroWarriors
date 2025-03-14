extends BattleAction

var hits = 2
func _ready():
	super._ready()
	action_name = "..." #Pipes
	description = "..." #Hits target n times
	verb = "..." #hit
	isMelee = true
	isPositive = false
	price = 2
	animationType = "throw"
	_validate_values_are_initialized()

func execute (user:BattleEntity, target:BattleEntity):
	super.execute(user,target)
	_meele_action()
	
func _action_effect()->void:
	target.receive_damage(user.attack)
