extends BattleAction

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	action_name = tr("BATTLE_ACTION_TAZE_NAME")
	description = tr("BATTLE_ACTION_TAZE_DESCRIPTION").format({multiplier=action_multiplier,stat=tr("BATTLESTAT_ATTACK")})
	verb = tr("BATTLE_ACTION_TAZE_VERB")

func _action_effect(target)->void:
	target.receive_damage(int(user.attack*action_multiplier))
