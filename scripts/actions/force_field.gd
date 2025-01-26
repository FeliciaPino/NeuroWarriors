extends BattleAction
var defense_effect = preload("res://scenes/status_effects/defense_up.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	action_name = "force field"
	description = "Summon a shield that increases defense for the next 2 turns"
	verb = "defend"
	isMelee = false
	isPositive = true
	price = 2
	animationType = "effect"
	_validate_values_are_initialized()
	

func execute (user:BattleEntity, target:BattleEntity):
	super.execute(user,target)
	_ranged_non_projectile_action(user, target)
func _action_effect(user:BattleEntity, target:BattleEntity)->void:
	
	var effect:StatusEffect = defense_effect.instantiate()
	effect.set_turns_remaining(2)
	effect.intensity = 10
	target.add_effect(effect)
