extends BattleAction
# Called when the node enters the scene tree for the first time.

func _ready() -> void:
	super._ready()
	action_name = "Heart"
	description = "Heals 30"
	verb = "heal"
	isMelee = false
	isPositive = true
	price = 3
	animationType = "effect"
	_validate_values_are_initialized()

func execute (user:BattleEntity, target:BattleEntity):
	super.execute(user,target)
	_projectile_action(user,target,10)
func _action_effect(user:BattleEntity, target:BattleEntity)->void:
	target.heal(30)
