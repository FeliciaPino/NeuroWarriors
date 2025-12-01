extends Resource
class_name Upgrade
enum UpgradeType {ENTITY_MOD,ABILITY_UNLOCK,ABILITY_MOD}
#ENTITY_MOD upgrades modify the associated battle entity at the start of battle (usally just increasing stats (like +5hp or something))
#ABILITY_UNLOCK upgrades just add an ability to the character's unlocked_abilites. It only does anything when it's purchased (or toggled)
#ABILITY_MOD upgrades... are weird I don't want to think about them
var name_id:String #The unique string identifier of this upgrade. 
var display_name:String #the name, but translated into the apropiate language
var description:String
var type:UpgradeType
var level_requirement:int
var tungesten_cost:int

var associated_ability:String #for ABILTY_UNLOCK and ABILITY_MOD Upgrades
#for ENTITY_MOD Upgrades. Please don't use on other ones.
func apply_to_entity(_entity:BattleEntity):
	pass
#for ABILITY_UNLOCK Upgrades
func purchased_effect():
	pass
	
