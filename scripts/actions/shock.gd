extends BattleAction
var shocked_effect = preload("res://scenes/status_effects/shocked.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	action_name = "Shock"
	description = "Damage distant target with power word shock. Causes enemies to be shocked for the next 2 turns. Removes target's accumulated AP"
	verb = "shock"
	isMelee = false
	isPositive = false
	price = 4
	animationType = "effect"

func execute (user:BattleEntity, target:BattleEntity):
	super.execute(user,target)
	_ranged_non_projectile_action(user,target)
func _action_effect(user:BattleEntity, target:BattleEntity)->void:
	
	var effect:StatusEffect = shocked_effect.instantiate()
	effect.set_turns_remaining(2)
	target.add_effect(effect)
	target.update_ap(0)
	target.receive_damage(user.attack)
