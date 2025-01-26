extends StatusEffect
class_name Status_Effect_Shocked

func _init() -> void:
	effect_name = "Shocked"
	description = "causes target to earn half of AP at start of turn" 
	turns_remaining = 1

func start_of_turn():
	super.start_of_turn()
	affected.update_ap(affected.actions_left - (affected.speed+1)/2)
