extends Node

var current_save_slot_index:int


var completed_levels: Dictionary
var flags:Dictionary
var characters_save_info:Dictionary
var overworld_info:Dictionary
#default values for things modified by save files, to start a new game with
const DEFAULT_VALUES = {
	"completed_levels" : {},
	"flags" : {
		"watched_intro_cutscene" : false,
		"watched_credits" : false
	},
	"characters_save_info":{
		"party":["Neuro-sama"],
		"Neuro-sama":{
			"unlocked":true,
			"level":0,
			"experience":0,
			"equiped_abilities":["robot_punch"],
			"unlocked_abilities":["robot_punch","heart"],
			"max_equiped_abilites":3,
			"active_upgrades":[],
			"unlocked_upgrades":[]
		},
		"Vedal":{
			"unlocked":false,
			"level":0,
			"experience":0,
			"equiped_abilities":[],
			"unlocked_abilities":[],
			"max_equiped_abilites":3,
			"active_upgrades":[],
			"unlocked_upgrades":[]
		},
		"Evil":{
			"unlocked":false,
			"level":0,
			"experience":0,
			"equiped_abilities":[],
			"unlocked_abilities":[],
			"max_equiped_abilites":3,
			"active_upgrades":[],
			"unlocked_upgrades":[]
		},
		"Anny":{
			"unlocked":false,
			"level":0,
			"experience":0,
			"equiped_abilities":[],
			"unlocked_abilities":[],
			"max_equiped_abilites":3,
			"active_upgrades":[],
			"unlocked_upgrades":[]
		}
	},
	"overworld_info":{
		"tungesten":0,
		"player_position_x":0,
		"player_position_y":-64,
		"defeated_enemies":{},
		"current_room_path":"res://scenes/overworld/overworld.tscn"
	}
}

var current_room_scene:PackedScene
var arrival_passage_name:String = "" #whihc passage entered the current room from (node name)

var current_level:String = ""
var current_enemy_battle:String = ""
var current_level_path:String = ""
var last_level = "City Boss"
func _ready():
	print("GameState is ready.")
	completed_levels = DEFAULT_VALUES["completed_levels"].duplicate(true)
	flags = DEFAULT_VALUES["flags"].duplicate(true)
	characters_save_info = DEFAULT_VALUES["characters_save_info"].duplicate(true)
	overworld_info = DEFAULT_VALUES["overworld_info"].duplicate(true)
	current_room_scene = load(overworld_info["current_room_path"])

func mark_level_complete(level_name: String):
	print(str(self,": level completed: ",level_name))
	completed_levels[level_name] = true
	if level_name == "Vedal unlock":
		unlock_character("Vedal")
	if level_name == "Evil unlock":
		unlock_character("Evil")
	if level_name == "Anny unlock":
		unlock_character("Anny")
func is_level_completed(level_name: String) -> bool:
	return completed_levels.get(level_name, false)
	
func mark_overworld_enemy_defeated(enemy_id:String):
	overworld_info["defeated_enemies"][enemy_id] = true
	SaveManager.save_game(current_save_slot_index)
func is_overworld_enemy_defeated(enemy_id:String):
	return overworld_info["defeated_enemies"].get(enemy_id,false)
func remove_overworld_enemy_defeated(enemy_id:String):
	overworld_info["defeated_enemies"][enemy_id]=false

func unlock_character(character_name:String):
	print(str(self,":unlocked ",character_name))
	characters_save_info[character_name]["unlocked"] = true
	if characters_save_info["party"].size() < CharacterDatabase.MAX_PARTY_SIZE:
		characters_save_info["party"].append(character_name)
func unlock_ability(character_name:String,ability_name:String):
	if not ability_name in characters_save_info[character_name]["unlocked_abilities"]:
		characters_save_info[character_name]["unlocked_abilities"]
		if characters_save_info[character_name]["equiped_abilities"].size()<characters_save_info[character_name]["max_equiped_abilites"]:
			characters_save_info[character_name]["equiped_abilities"].append(ability_name)
func is_character_unlocked(character_name:String):
	return characters_save_info[character_name]["unlocked"]
func is_character_in_party(character_name):
	return character_name in characters_save_info["party"]

func character_has_upgrade(character_name:String,upgrade_name:String)->bool:
	var ans = false
	if upgrade_name in characters_save_info[character_name]["active_upgrades"]: ans = true
	if upgrade_name in characters_save_info[character_name]["unlocked_upgrades"]: ans = true
	return ans
func is_upgrade_active(character_name:String,upgrade_name:String)->bool:
	return upgrade_name in characters_save_info[character_name]["active_upgrades"]
func activate_upgrade(character_name:String, upgrade_name:String):
	if not character_has_upgrade(character_name,upgrade_name): return
	var active_upgrades = characters_save_info[character_name]["active_upgrades"]
	var unlocked_upgrades = characters_save_info[character_name]["unlocked_upgrades"]
	if upgrade_name in unlocked_upgrades:
		unlocked_upgrades.erase(upgrade_name)
	if not upgrade_name in active_upgrades:
		active_upgrades.append(upgrade_name)
func deactivate_upgrade(character_name:String, upgrade_name:String):
	if not character_has_upgrade(character_name,upgrade_name): return
	var active_upgrades = characters_save_info[character_name]["active_upgrades"]
	var unlocked_upgrades = characters_save_info[character_name]["unlocked_upgrades"]
	if not upgrade_name in unlocked_upgrades:
		unlocked_upgrades.append(upgrade_name)
	if upgrade_name in active_upgrades:
		active_upgrades.erase(upgrade_name)
func unlock_upgrade(character_name:String, upgrade_name:String):
	var unlocked_upgrades = characters_save_info[character_name]["unlocked_upgrades"]
	if not upgrade_name in unlocked_upgrades:
		unlocked_upgrades.append(upgrade_name)
	
func set_party(party:Array[String]):
	characters_save_info["party"] = party
func get_party():
	return characters_save_info["party"]
func get_player_map_position():
	return Vector2(overworld_info["player_position_x"],overworld_info["player_position_y"])
	
func set_player_map_position(position:Vector2):
	overworld_info["player_position_x"] = position.x
	overworld_info["player_position_y"] = position.y
func get_tungesten_amount()->int:
	return overworld_info["tungesten"]
func set_tungesten_amount(new_value:int):
	overworld_info["tungesten"] = new_value
func increase_tungesten_amount(amount:int):
	overworld_info["tungesten"] += amount

func go_to_map():
	print(str(self,": going to map, loading scene ",current_room_scene))
	get_tree().change_scene_to_packed(current_room_scene)
const level_select_scene = preload("res://scenes/levels/level_select.tscn")
const map_scene = preload("res://scenes/overworld/overworld.tscn")
const intro_cutscene_scene = preload("res://scenes/intro_cutscene.tscn")
func start_game():
	if flags["watched_intro_cutscene"]:
		go_to_map()
	else:
		get_tree().change_scene_to_packed(intro_cutscene_scene)

#called when the GameState is deleted, which should be never
func _exit_tree():
	print("GameState is trying to exit the tree!")
	#self.duplicate(false)  # Ensures it's not accidentally freed
