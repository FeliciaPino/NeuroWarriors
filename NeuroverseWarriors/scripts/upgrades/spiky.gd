extends Upgrade

func _init():
	type = UpgradeType.PASSIVE_ABILITY
	name_id = "spiky"
	display_name = tr("SKILL_TREE_UPGRADE_SHARP_HORNS_NAME")
	description = tr("SKILL_TREE_UPGRADE_SHARP_HORNS_DESCRIPTION")
	associated_ability = "spiky"
