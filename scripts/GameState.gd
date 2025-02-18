extends Node

var current_save_slot_index:int


var completed_levels: Dictionary
var flags:Dictionary
#default values for things modified by save files, to start a new game with
const DEFAULT_VALUES = {
	"completed_levels" : {},
	"flags" : {
		"watched_intro_cutscene" : false,
		"watched_credits" : false
	}
}

var current_level:String = ""
var last_level = "The End"
var is_neuro_controlling = false
func _ready():
	print("GameState is ready.")
	
func mark_level_complete(level_name: String):
	completed_levels[level_name] = true

func is_level_completed(level_name: String) -> bool:
	return completed_levels.get(level_name, false)

#called when the GameState is deleted, which should be never
func _exit_tree():
	print("GameState is trying to exit the tree!")
	#self.duplicate(false)  # Ensures it's not accidentally freed
