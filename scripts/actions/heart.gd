extends BattleAction
# Called when the node enters the scene tree for the first time.

func _ready() -> void:
	super._ready()
	action_name = "Heart"
	description = "Heals 33"
	verb = "heal"
	isMelee = false
	isPositive = true
	price = 3
	animationType = "effect"
	_validate_values_are_initialized()

func execute (user:BattleEntity, target:BattleEntity):
	super.execute(user,target)
	_projectile_action(400)
func _action_effect()->void:
	target.heal(33)
