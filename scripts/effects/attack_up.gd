extends StatusEffect
class_name Status_Effect_Defense_Up
func _init() -> void:
	effect_name = "Attack Up"
	description = "Increases attack stat"
	turns_remaining = 3
	intensity = 3


func start_effect():
	super.start_effect()
	affected.attack += intensity
	
func end_effect():
	super.end_effect()
	affected.attack -= intensity
