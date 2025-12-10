extends Upgrade
const INCREASE_AMOUNT = 1
func _init():
	type = UpgradeType.OTHER
	name_id = "better_ram"
	display_name = tr("SKILL_TREE_UPGRADE_BETTER_RAM_NAME")
	description = tr("SKILL_TREE_UPGRADE_INCREASE_MAX_EQUIPPED_ABILITIES_DESCRIPTION").format({amount=INCREASE_AMOUNT})
func purchased_effect(_associated_character):
	GameState.set_character_max_equiped_actions(_associated_character,GameState.get_character_max_equiped_actions(_associated_character)+INCREASE_AMOUNT)
func deactivated_effect(_associated_character:String):
	GameState.set_character_max_equiped_actions(_associated_character,GameState.get_character_max_equiped_actions(_associated_character)-INCREASE_AMOUNT)
