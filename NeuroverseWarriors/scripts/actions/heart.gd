extends BattleAction

var heal_amount = 33
func _ready() -> void:
	super._ready()
	action_name = tr("BATTLE_ACTION_HEART_NAME")
	description = tr("BATTLE_ACTION_HEART_DESCRIPTION").format({amount=heal_amount})
	verb = tr("BATTLE_ACTION_HEART_VERB")

func _action_effect()->void:
	current_target.heal(heal_amount)
