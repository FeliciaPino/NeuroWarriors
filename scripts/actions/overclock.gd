extends BattleAction
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	action_name = tr("BATTLE_ACTION_OVERCLOCK_NAME")
	description = tr("BATTLE_ACTION_OVERCLOCK_DESCRIPTION").format({stat=tr("BATTLESTAT_AP_REGEN")})
	verb = tr("BATTLE_ACTION_OVERCLOCK_VERB")
	isMelee = false
	isPositive = true
	price = 2
	animationType = "effect"
	_validate_values_are_initialized()
	

func execute (user:BattleEntity, target:BattleEntity):
	super.execute(user,target)
	_ranged_non_projectile_action()
func _action_effect()->void:
	target.reduce_health(1)
	target.update_ap(target.ap + 2)
