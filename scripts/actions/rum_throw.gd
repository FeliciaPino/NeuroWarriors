extends BattleAction
# Called when the node enters the scene tree for the first time.
var poisoned_effect = preload("res://scenes/status_effects/poisoned.tscn")

func _ready() -> void:
	super._ready()
	action_name = "Rum Throw"
	description = "Throws very strong rum at target, poisoning them"
	verb = "throw rum at"
	isMelee = false
	isPositive = false
	price = 2
	animationType = "throw"
	_validate_values_are_initialized()

func execute (user:BattleEntity, target:BattleEntity):
	super.execute(user,target)
	_projectile_action(600)
	
func _action_effect()->void:
	var effect:StatusEffect = poisoned_effect.instantiate()
	effect.intensity = user.attack
	target.add_effect(effect)
	if target.entity_name == "Vedal":
		target.heal(20)
		return
	target.receive_damage(user.attack)
