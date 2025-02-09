extends BattleAction
var shocked_effect = preload("res://scenes/status_effects/shocked.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	action_name = "Shock"
	description = "Damage distant target with power word shock. Causes target to earn half as much AP the next 2 turns."
	verb = "shock"
	isMelee = false
	isPositive = false
	price = 4
	animationType = "effect"
	_validate_values_are_initialized()

func execute (user:BattleEntity, target:BattleEntity):
	super.execute(user,target)
	_ranged_non_projectile_action(user,target)
func _action_effect(user:BattleEntity, target:BattleEntity)->void:
	
	var effect:StatusEffect = shocked_effect.instantiate()
	effect.set_turns_remaining(2)
	target.add_effect(effect)
	target.receive_damage(user.attack*2)
