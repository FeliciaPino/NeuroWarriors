extends BattleAction
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	action_multiplier = 1.75
	action_name = tr("BATTLE_ACTION_HARPOON_THROW_NAME")
	description = tr("BATTLE_ACTION_HARPOON_THROW_DESCRIPTION").format({multiplier=action_multiplier,stat=tr("BATTLESTAT_ATTACK")})
	verb = tr("BATTLE_ACTION_HARPOON_THROW_VERB")
	isMelee = false
	isPositive = false
	price = 3
	animationType = "throw"
	_validate_values_are_initialized()

func execute (user:BattleEntity, target:BattleEntity):
	super.execute(user,target)
	_projectile_action(600)
func _action_effect()->void:
	target.receive_damage(user.attack * action_multiplier)
