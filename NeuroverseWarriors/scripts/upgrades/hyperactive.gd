extends Upgrade

const AP_REGEN_INCREASE = 1
func _init():
	type = UpgradeType.ENTITY_MOD
	name_id = "hyperactive"
	display_name = tr("SKILL_TREE_UPGRADE_HYPERACTIVE_NAME")
	description = tr("SKILL_TREE_UPGRADE_HYPERACTIVE_DESCRIPTION").format({amount=AP_REGEN_INCREASE})
func apply_to_entity(_entity:BattleEntity):
	_entity.ap_regen += AP_REGEN_INCREASE
