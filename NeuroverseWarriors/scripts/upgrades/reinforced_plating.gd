extends Upgrade

const DEFENSE_INCREASE = 4
func _init():
	type = UpgradeType.ENTITY_MOD
	name_id = "reinforced_plating"
	display_name = tr("SKILL_TREE_UPGRADE_REINFORCED_PLATING_NAME")
	description = tr("SKILL_TREE_UPGRADE_REINFORCED_PLATING_DESCRIPTION").format({amount=DEFENSE_INCREASE})

	
func apply_to_entity(entity:BattleEntity):
	entity.defense += DEFENSE_INCREASE
