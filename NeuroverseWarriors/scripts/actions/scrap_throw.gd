extends BattleAction

func _ready() -> void:
	super._ready()
	action_name = tr("BATTLE_ACTION_SCRAP_THROW_NAME")
	description = tr("BATTLE_ACTION_SCRAP_THROW_DESCRIPTION").format({})
	verb = tr("BATTLE_ACTION_SCRAP_THROW_VERB")
	

func _action_effect(target:BattleEntity)->void:
	target.receive_damage(int(user.attack * action_multiplier))
