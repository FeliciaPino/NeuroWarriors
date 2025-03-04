extends StatusEffect

func _init() -> void:
	effect_name = tr("STATUS_EFFECT_SHOCKED_NAME")
func get_description():
	return tr("STATUS_EFFECT_SHOCKED_DESCRIPTION")
func start_of_turn():
	super.start_of_turn()
	affected.update_ap(affected.ap - (affected.speed+1)/2)
