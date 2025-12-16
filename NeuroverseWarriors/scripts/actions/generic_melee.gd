extends BattleAction

func _ready():
	super._ready()
	action_name = tr("BATTLE_ACTION_GENERIC_MELEE_NAME")
	description = tr("BATTLE_ACTION_GENERIC_MELEE_DESCRIPTION")
	verb = tr("BATTLE_ACTION_GENERIC_MELEE_VERB")

func _action_effect(target)->void:
	target.receive_damage(user.attack*2)
