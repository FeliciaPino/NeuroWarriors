extends BattleAction
# Called when the node enters the scene tree for the first time.
var poisoned_effect = preload("res://scenes/status_effects/poisoned.tscn")

func _ready() -> void:
	super._ready()
	action_name = "Poison Dart"
	description = "Poisons target"
	verb = "poison"
	isMelee = false
	isPositive = false
	price = 2
	animationType = "throw"
	_validate_values_are_initialized()

func execute (user:BattleEntity, target:BattleEntity):
	super.execute(user,target)
	_projectile_action(user,target,15)
	
func _action_effect(user:BattleEntity, target:BattleEntity)->void:
	var effect:StatusEffect = poisoned_effect.instantiate()
	effect.intensity = user.attack
	effect.turns_remaining = 4
	target.add_effect(effect)
	target.receive_damage(5)
