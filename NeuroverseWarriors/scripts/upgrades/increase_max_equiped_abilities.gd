extends Upgrade
const DEFENSE_INCREASE = 4
func _init():
	type = UpgradeType.OTHER
	name_id = "increase_max_equiped_abilities"
	display_name = tr("SKILL_TREE_UPGRADE_INCREASE_MAX_EQUIPED_ABILITIES_NAME")
	description = tr("SKILL_TREE_UPGRADE_INCREASE_MAX_EQUIPED_ABILITIES_DESCRIPTION")
	level_requirement = 6
	tungesten_cost = 15
