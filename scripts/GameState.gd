extends Node

var completed_levels: Dictionary = {}
var current_level:String = ""
var last_level = "The End"
var wached_intro_cutscene = false
var watched_credits = false
var is_neuro_controlling = false

func _ready():
	wached_intro_cutscene = false
	print("GameState is ready.")
	
func mark_level_complete(level_name: String):
	completed_levels[level_name] = true

func is_level_completed(level_name: String) -> bool:
	return completed_levels.get(level_name, false)
func _exit_tree():
	print("GameState is trying to exit the tree!")
	#self.duplicate(false)  # Ensures it's not accidentally freed
