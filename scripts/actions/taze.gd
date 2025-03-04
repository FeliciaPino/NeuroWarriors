extends BattleAction

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	action_name = tr("BATTLE_ACTION_TAZE_NAME")
	description = tr("BATTLE_ACTION_TAZE_DESCRIPTION").format({multiplier=action_multiplier,stat=tr("BATTLESTAT_ATTACK")})
	verb = tr("BATTLE_ACTION_TAZE_VERB")
	isMelee = true
	isPositive = false
	price = 2
	animationType = "attack"
	_validate_values_are_initialized()

func execute (user:BattleEntity, target:BattleEntity):
	super.execute(user,target)
	_meele_action()
func _action_effect()->void:
	target.receive_damage(user.attack*2)
