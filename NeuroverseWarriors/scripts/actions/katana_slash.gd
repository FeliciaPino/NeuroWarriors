extends BattleAction

func _ready():
	super._ready()
	action_name = tr("BATTLE_ACTION_KATANA_SLASH_NAME")
	description = tr("BATTLE_ACTION_KATANA_SLASH_DESCRIPTION").format({multiplier=action_multiplier,stat=tr("BATTLESTAT_ATTACK")})

func _action_effect(target)->void:
	target.receive_damage(int(user.attack*action_multiplier))
	
