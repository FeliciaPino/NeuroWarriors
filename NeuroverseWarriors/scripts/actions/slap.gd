extends BattleAction

func _ready():
	super._ready()
	action_name = tr("BATTLE_ACTION_SLAP_NAME")
	description = tr("BATTLE_ACTION_SLAP_DESCRIPTION").format({multiplier=action_multiplier,stat=tr("BATTLESTAT_ATTACK")})
	verb = tr("BATTLE_ACTION_SLAP_VERB")
func _action_effect()->void:
	super._action_effect()
	current_target.receive_damage(int(user.attack*action_multiplier))
