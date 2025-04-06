extends Node

const CHARACTER_SCENE_PATHS = {
	"Neuro-sama":"res://scenes/characters/neuro_sama.tscn",
	"Vedal":"res://scenes/characters/vedal.tscn",
	"Evil":"res://scenes/characters/evil.tscn",
	"Anny":"res://scenes/characters/anny.tscn"
}
const ALL_CHARACTERS = [
	"Neuro-sama",
	"Vedal",
	"Evil",
	"Anny"
]
const MAX_PARTY_SIZE = 3

func get_entity_scene(name:String) -> PackedScene:
	print(str(self,": loading ",name))
	return load(CHARACTER_SCENE_PATHS[name])
	
#called when instantiating a character, to modify their stats according to their level
func apply_level(battle_entity:BattleEntity,level:int)->void:
	battle_entity.maxHealth += int(level*battle_entity.maxHealth*0.02)
	battle_entity.health = battle_entity.maxHealth
	battle_entity.attack += int(battle_entity.attack*0.02*level)

#Checks GameState to see if the current xp a character has is enough to level them up, returns wether or not they leveld up, and levels up the character in GameState
func level_up_if_needed(character_name:String)->bool:
	var current_level = GameState.characters_save_info[character_name]["level"]
	var current_xp = GameState.characters_save_info[character_name]["experience"]
	var xp_cost_to_level_up = xp_needed_to_level_up(current_level)
	if current_xp >= xp_cost_to_level_up:
		GameState.characters_save_info[character_name]["level"] = int(current_level + 1)
		GameState.characters_save_info[character_name]["experience"] = int(current_xp-xp_cost_to_level_up)
		return true
	return false
func xp_needed_to_level_up(current_level:int)->int:
	return 10*current_level*current_level+100
#gives the character the amount of experience and checks for level up
func gain_xp(character_name:String, xp_amount:int)->bool:
	GameState.characters_save_info[character_name]["experience"] += xp_amount
	return level_up_if_needed(character_name)
