extends BattleAction
# Called when the node enters the scene tree for the first time.

func _ready() -> void:
	action_name = "Laser Shot"
	description = "Shoots a laser"
	verb = "shoot a laser at"
	isMelee = false
	isPositive = false
	price = 1
	animationType = "effect"

func execute (user:BattleEntity, target:BattleEntity):
	super.execute(user,target)
	_projectile_action(user,target,60)
func _action_effect(user:BattleEntity, target:BattleEntity)->void:
	target.receive_damage(user.attack)
