extends BattleAction
# Called when the node enters the scene tree for the first time.

func _ready() -> void:
	super._ready()
	action_name = "Harpoon Throw"
	description = "Throws a heavy harpoon at target"
	verb = "throw harpoon at"
	isMelee = false
	isPositive = false
	price = 3
	animationType = "throw"
	_validate_values_are_initialized()

func execute (user:BattleEntity, target:BattleEntity):
	super.execute(user,target)
	_projectile_action(user,target,20)
func _action_effect(user:BattleEntity, target:BattleEntity)->void:
	target.receive_damage(user.attack * 2.5)
