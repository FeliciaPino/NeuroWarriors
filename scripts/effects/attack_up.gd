extends StatusEffect
func _init() -> void:
	effect_name = tr("STATUS_EFFECT_ATTACK_UP_NAME")

func get_description():
	return tr("STATUS_EFFECT_ATTACK_UP_DESCRIPTION").format({amount=intensity})

func start_effect():
	super.start_effect()
	affected.attack += intensity
	
func end_effect():
	super.end_effect()
	affected.attack -= intensity
