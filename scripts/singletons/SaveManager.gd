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
		print_debug("error saving, could not open file")
		return
	file.store_string(JSON.stringify(dict))
	
func save_game(save_slot_index:int):
	var directory_path = str("user://saves/slot",save_slot_index)
	print_debug(str(self)+": saving to ", ProjectSettings.globalize_path(directory_path))
	ensure_directory(directory_path)
	
	save_dict(GameState.completed_levels,directory_path+"/levels.json")
	save_dict(GameState.flags, directory_path+"/flags.json")
	save_dict(GameState.characters_save_info, directory_path+"/characters.json")
	save_dict(GameState.overworld_info, directory_path+"/overworld_info.json")

func _load_dict(dict:Dictionary, default:Dictionary, file_path:String):
	if not FileAccess.file_exists(file_path):
		print_debug("dictionary missing, initializing values")
		for key in default:
			if default[key] is Dictionary:
				dict[key] = default[key].duplicate(true)
			else:
				dict[key] = default[key]
		return
	var file = FileAccess.open(file_path,FileAccess.READ)
	if file == null:
		print_debug("there was an error opening the file" + file_path)
	var json_string = file.get_as_text()
	file.close()
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	if not parse_result == OK:
		#I should have better error handling
		print_debug("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
		return
	#I *think* I could change this for just a .duplicate(true). I'm not sure how Dictionarys work tho. and this works so...
	for key in json.data:
		if json.data[key] is Dictionary:
			print_debug(str(self)+": "+ key + " a sub dictionary")
			dict[key] = json.data[key].duplicate(true)
		else:
			print_debug(str(self)+": "+key+" just a regular value")
			dict[key] = json.data[key]
	for key in default:
		if not dict.has(key):
			dict[key] = default[key]

func load_game(save_slot_index:int):
	var directory = str("user://saves/slot",save_slot_index)
	ensure_directory(directory)
	_load_dict(GameState.completed_levels, GameState.DEFAULT_VALUES["completed_levels"], directory+"/levels.json")
	_load_dict(GameState.flags, GameState.DEFAULT_VALUES["flags"], directory+"/flags.json")
	_load_dict(GameState.characters_save_info,GameState.DEFAULT_VALUES["flags"], directory+"/characters.json")
	_load_dict(GameState.overworld_info,GameState.DEFAULT_VALUES["overworld_info"], directory+"/overworld_info.json")
	print_debug(str(self,": loading into room: ",GameState.overworld_info["current_room_path"]))
	GameState.current_room_scene = load(GameState.overworld_info["current_room_path"])
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
	
