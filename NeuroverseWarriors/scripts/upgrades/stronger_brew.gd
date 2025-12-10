extends Upgrade
const DAMAGE_INCREASE = 4
func _init() -> void:
	type = UpgradeType.ABILITY_MOD
	name_id = "stronger_brew"
	display_name = tr("SKILL_TREE_UPGRADE_STRONGER_BREW_NAME")
	description = tr("SKILL_TREE_UPGRADE_STRONGER_BREW_DESCRIPTION").format({ability_name=tr("BATTLE_ACTION_RUM_THROW_NAME"),amount=DAMAGE_INCREASE})
	associated_ability = "rum_throw"
func apply_to_battle_action(_battle_action:BattleAction):
	_battle_action.effect_intensity += DAMAGE_INCREASE
