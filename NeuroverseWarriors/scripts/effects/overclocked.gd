extends StatusEffect
func _init() -> void:
	effect_name = tr("STATUS_EFFECT_OVERCLOCKED_NAME")
func get_description():
		return tr("STATUS_EFFECT_OVERCLOCKED_DESCRIPTION").format({stat=tr("BATTLESTAT_AP_REGEN") ,amount=intensity,amount2=intensity*7})

func start_effect():
	super.start_effect()
	affected.ap_regen += intensity
	
func start_of_turn():
	super.start_of_turn()
	affected.reduce_health(intensity*5)

func end_effect():
	super.end_effect()
	affected.ap_regen -= intensity
