extends BattleAction
# Called when the node enters the scene tree for the first time.

func _ready() -> void:
	super._ready()
	action_name = "Repair"
	description = "Heals"
	verb = "heal"
	isMelee = false
	isPositive = true
	price = 2
	animationType = "throw"
	_validate_values_are_initialized()

func execute (user:BattleEntity, target:BattleEntity):
	super.execute(user,target)
	_projectile_action(user,target,15)
	
func _action_effect(user:BattleEntity, target:BattleEntity)->void:
	target.heal(20)
