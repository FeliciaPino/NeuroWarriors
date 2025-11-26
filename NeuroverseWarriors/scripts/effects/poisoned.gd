extends StatusEffect
func _init() -> void:
	effect_name = tr("STATUS_EFFECT_POISONED_NAME")
func get_description():
	return tr("STATUS_EFFECT_POISONED_DESCRIPTION").format({amount=intensity})
func start_of_turn():
	super.start_of_turn()
	affected.reduce_health(intensity)
