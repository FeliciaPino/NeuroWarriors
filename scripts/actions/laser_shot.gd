extends BattleAction
# Called when the node enters the scene tree for the first time.

func _ready() -> void:
	super._ready()
	action_name = "Laser Shot"
	description = "Shoots a laser"
	verb = "shoot a laser at"
	isMelee = false
	isPositive = false
	price = 1
	animationType = "effect"
	_validate_values_are_initialized()

func execute (user:BattleEntity, target:BattleEntity):
	super.execute(user,target)
	_projectile_action(2500)
func _action_effect()->void:
	target.receive_damage(user.attack)
