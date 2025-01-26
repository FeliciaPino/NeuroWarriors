extends StatusEffect
class_name Status_Effect_Poisoned
func _init() -> void:
	effect_name = "Poisoned"
	description = "Takes damage at the start of each turn" 
	turns_remaining = 3
	intensity = 5

func start_of_turn():
	super.start_of_turn()
	affected.reduce_health(intensity)
