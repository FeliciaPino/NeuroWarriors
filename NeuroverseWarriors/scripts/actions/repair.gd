extends BattleAction
# Called when the node enters the scene tree for the first time.

func _ready() -> void:
	super._ready()
	action_name = tr("BATTLE_ACTION_REPAIR_NAME")
	description = tr("BATTLE_ACTION_REPAIR_DESCRIPTION").format({amount=20})
	verb = tr("BATTLE_ACTION_REPAIR_VERB")

func _action_effect()->void:
	current_target.heal(int(20*action_multiplier))
