extends BattleAction
# Called when the node enters the scene tree for the first time.

func _ready() -> void:
	super._ready()
	action_name = tr("BATTLE_ACTION_LASER_SHOOT_NAME")
	description = tr("BATTLE_ACTION_LASER_SHOOT_DESCRIPTION").format({multiplier=action_multiplier,stat=tr("BATTLESTAT_ATTACK")})
	verb = tr("BATTLE_ACTION_LASER_SHOOT_VERB")

func _action_effect()->void:
	current_target.receive_damage(user.attack)
