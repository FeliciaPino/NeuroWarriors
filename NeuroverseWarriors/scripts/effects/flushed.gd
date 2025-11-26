extends StatusEffect
func _init() -> void:
	effect_name = tr("STATUS_EFFECT_FLUSHED_NAME")
func get_description():
	return tr("STATUS_EFFECT_FLUSHED_DESCRIPTION").format({amount=intensity})
func start_effect():
	super.start_effect()
	affected.attack -= intensity
	affected.defense -= intensity
	
func end_effect():
	super.end_effect()
	affected.attack += intensity
	affected.defense += intensity
