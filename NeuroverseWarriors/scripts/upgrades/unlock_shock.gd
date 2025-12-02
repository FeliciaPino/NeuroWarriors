extends Upgrade

func _init():
	type = UpgradeType.ABILITY_UNLOCK
	name_id = "unlock_shock"
	display_name = tr("SKILL_TREE_UPGRADE_UNLOCK_SHOCK_NAME")
	description = tr("SKILL_TREE_UPGRADE_UNLOCK_SHOCK_DESCRIPTION")
	level_requirement = 10
	tungesten_cost = 20
	associated_ability = "shock"
