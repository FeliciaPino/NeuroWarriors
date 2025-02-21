extends Node

var current_save_slot_index:int


var completed_levels: Dictionary
var flags:Dictionary
var characters_save_info:Dictionary
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
			"level":1,
			"experience":0
		},
		"Vedal":{
			"unlocked":false,
			"level":1,
			"experience":0
		},
		"Evil":{
			"unlocked":false,
			"level":1,
			"experience":0
		}
	}
}

var current_level:String = ""
var current_level_path:String = ""
var last_level = "The End"
func _ready():
	print("GameState is ready.")
	completed_levels = DEFAULT_VALUES["completed_levels"].duplicate(true)
	flags = DEFAULT_VALUES["flags"].duplicate(true)
	characters_save_info = DEFAULT_VALUES["characters_save_info"].duplicate(true)



func mark_level_complete(level_name: String):
	completed_levels[level_name] = true
	if level_name == "Vedal’s Refuge":
		characters_save_info["Vedal"]["unlocked"] = true
		if not "Vedal" in characters_save_info["party"]:
			characters_save_info["party"].append("Vedal")
	if level_name == "De-fence, HO, HO!":
		characters_save_info["Evil"]["unlocked"] = true
		if not "Evil" in characters_save_info["party"]:
			characters_save_info["party"].append("Evil")
		
	SaveManager.save_game(current_save_slot_index)
func is_level_completed(level_name: String) -> bool:
	return completed_levels.get(level_name, false)
const level_select_scene = preload("res://scenes/levels/level_select.tscn")
const intro_cutscene_scene = preload("res://scenes/intro_cutscene.tscn")
func start_game():
	if flags["watched_intro_cutscene"]:
		get_tree().change_scene_to_packed(level_select_scene)
	else:
		get_tree().change_scene_to_packed(intro_cutscene_scene)

#called when the GameState is deleted, which should be never
func _exit_tree():
	print("GameState is trying to exit the tree!")
	#self.duplicate(false)  # Ensures it's not accidentally freed
