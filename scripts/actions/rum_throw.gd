extends BattleAction
# Called when the node enters the scene tree for the first time.
var poisoned_effect = preload("res://scenes/status_effects/poisoned.tscn")

func _ready() -> void:
	action_name = "Rum Throw"
	description = "Throws very strong rum at target, poisoning them"
	verb = "throw rum at"
	isMelee = false
	isPositive = false
	price = 2
	animationType = "throw"

func execute (user:BattleEntity, target:BattleEntity):
	super.execute(user,target)
	_projectile_action(user,target,15)
	
func _action_effect(user:BattleEntity, target:BattleEntity)->void:
	var effect:StatusEffect = poisoned_effect.instantiate()
	effect.intensity = user.attack
	target.add_effect(effect)
	target.receive_damage(user.attack)
