extends StatusEffect
class_name Status_Effect_Attack_Up
func _init() -> void:
	effect_name = "Defense Up"
	description = "Increases defence, substracting damage taken" 
	turns_remaining = 3
	intensity = 3


func start_effect():
	super.start_effect()
	affected.defense += intensity
	
func end_effect():
	super.end_effect()
	affected.defense -= intensity
