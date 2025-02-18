extends Node
# Called when the node enters the scene tree for the first time.
func _ready():
	#Check if save directories exist
	ensure_directory("user://saves")
		
	#Posibly check if the saves aren't corrupted or anything. Maybe. In the future
func ensure_directory(path:String):
	if not DirAccess.dir_exists_absolute(path): DirAccess.make_dir_absolute(path)
	

func save_dict(dict:Dictionary, file_path:String)->void:
	var file = FileAccess.open(file_path,FileAccess.WRITE)
	if not file:
		print("error saving, could not open file")
		return
	file.store_string(JSON.stringify(dict))
	
func save_game(save_slot_index:int):
	var directory = str("user://saves/slot",save_slot_index)
	ensure_directory(directory)
	
	save_dict(GameState.completed_levels,directory+"/levels.json")
	save_dict(GameState.flags, directory+"/flags.json")

#returns the loaded dictionary
func load_dict(file_path:String):
	if not FileAccess.file_exists(file_path):
		print("dictionary missing")
		return null
	var file = FileAccess.open(file_path,FileAccess.READ)
	var json_string = file.get_as_text()
	file.close()
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	if not parse_result == OK:
		#I should have better error handling
		print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
		return null
	return json.data

func load_game(save_slot_index:int):
	var directory = str("user://saves/slot",save_slot_index)
	ensure_directory(directory)
	var loaded_dict = load_dict(directory+"/levels.json")
	if loaded_dict != null:
		GameState.completed_levels = loaded_dict
	else:
		GameState.completed_levels = GameState.DEFAULT_VALUES["completed_levels"].duplicate()
	loaded_dict = load_dict(directory+"/flags.json")
	if loaded_dict != null:
		GameState.flags = loaded_dict
	else:
		GameState.flags = GameState.DEFAULT_VALUES["flags"].duplicate()
	
