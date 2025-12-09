extends Upgrade
const DAMAGE_INCREASE = 2
func _init():
	type = UpgradeType.ENTITY_MOD
	name_id = "horns"
	display_name = tr("SKILL_TREE_UPGRADE_HORNS_NAME")
	description = tr("SKILL_TREE_UPGRADE_HORNS_DESCRIPTION").format({amount=DAMAGE_INCREASE})

	
func apply_to_entity(entity:BattleEntity):
	entity.attack += DAMAGE_INCREASE
