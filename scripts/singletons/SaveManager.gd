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
	var directory_path = str("user://saves/slot",save_slot_index)
	ensure_directory(directory_path)
	
	save_dict(GameState.completed_levels,directory_path+"/levels.json")
	save_dict(GameState.flags, directory_path+"/flags.json")
	save_dict(GameState.characters_save_info, directory_path+"/characters.json")

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
		GameState.completed_levels = GameState.DEFAULT_VALUES["completed_levels"].duplicate(true)
		
	loaded_dict = load_dict(directory+"/flags.json")
	if loaded_dict != null:
		GameState.flags = loaded_dict
	else:
		GameState.flags = GameState.DEFAULT_VALUES["flags"].duplicate(true)
		
	
	loaded_dict = load_dict(directory+"/characters.json")
	if loaded_dict != null:
		GameState.characters_save_info = loaded_dict
	else:
		GameState.characters_save_info = GameState.DEFAULT_VALUES["characters_save_info"].duplicate(true)
func get_save_info(save_slot_index):
	var directory_path = str("user://saves/slot",save_slot_index)
	ensure_directory(directory_path)
	var directory = DirAccess.open(directory_path)
	var files = directory.get_files()
	if files.size()==0:
		return {}
	return {"something":"something"}#I still don't really have any pertinent information for the saves to show
func delete_save(save_slot_index:int):
	var directory_path = str("user://saves/slot",save_slot_index)
	ensure_directory(directory_path)
	var dir = DirAccess.open(directory_path)
	for file in dir.get_files():
		dir.remove(directory_path + "/" + file)
	
