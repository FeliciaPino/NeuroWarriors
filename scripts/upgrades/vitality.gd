extends Upgrade
const HEALTH_INCREASE = 8
func _init():
	type = UpgradeType.ENTITY_MOD
	name_id = "vitality"
	display_name = tr("SKILL_TREE_UPGRADE_VITALITY_NAME")
	description = tr("SKILL_TREE_UPGRADE_VITALITY_DESCRIPTION").format({amount=HEALTH_INCREASE})
	level_requirement = 6
	tungesten_cost = 10
	
func apply_to_entity(entity:BattleEntity):
	entity.maxHealth += HEALTH_INCREASE
