extends StatusEffect
func _init() -> void:
	effect_name = tr("STATUS_EFFECT_HYPED_NAME")
func get_description():
	return tr("STATUS_EFFECT_HYPED_DESCRIPTION").format({amount=intensity/2,amount2=intensity})
func start_effect():
	super.start_effect()
	affected.attack += intensity/2
	
func end_effect():
	super.end_effect()
	affected.attack -= intensity/2

func start_of_turn():
	super.start_of_turn()
	affected.heal(intensity)
