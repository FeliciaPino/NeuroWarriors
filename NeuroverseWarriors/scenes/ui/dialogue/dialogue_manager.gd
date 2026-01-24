extends Node
class_name DialogueManager
signal dialogue_started
signal dialogue_ended

@onready var dialogue_display := %DialogueDisplay
@onready var timer:Timer = $Timer
@onready var room:Room = $".."
var sequence = {}
var current_line = {}
#This is called by the dialogue triggers
func start_dialogue(path_to_dialogue_sequence_json:String):
	dialogue_started.emit()
	room.current_mode = Room.Mode.DIALOGUE
	dialogue_display.clear()
	var file = FileAccess.open(path_to_dialogue_sequence_json,FileAccess.READ)
	if file == null:
		print_debug("there was an error opening the file" + path_to_dialogue_sequence_json)
	var json_string = file.get_as_text()
	file.close()
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	if not parse_result == OK:
		print_debug("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
		return
	
	sequence = {}
	print_debug("building sequence")
	for line in json.data:
		var id = line.get("id","")
		if id != "":
			if sequence.has("id"):push_error("Duplicate dialogue id: " + id)
			sequence[id] = line
			print_debug(str("adding id:",id))
	current_line = sequence.get("start",null)
	if not current_line:
		push_error("Dialogue JSON missing start line")
	dialogue_display.visible = true
	_next_line()
	_show_current_line()
	timer.start()
	get_tree().paused = true
func _show_current_line():
	print_debug(str("showing line: ",current_line["id"]))
	var speaker_to_display = _get_speaker_from_line(current_line)
	dialogue_display.typing_speed = current_line.get("speed",dialogue_display.DEFAULT_TYPING_SPEED)
	dialogue_display.display_line(speaker_to_display,current_line.get("expression",""),tr(current_line["text_key"]))
	
func _get_speaker_from_line(dialogue_line):
	var speaker = current_line.get("speaker","")
	if speaker is Array:
		var options = speaker
		speaker = ""
		#select first character from list in party
		for possible_speaker in options:
			if character_in_party(possible_speaker):
				speaker = possible_speaker
				break
		#If none of the options are in the party, default to first one (possibly more logic later down the line)
		if speaker == "":
			speaker = options[0]
	#update it to make further queries more efficientt
	current_line["speaker"] = speaker
	return speaker
func _next_line():
	print_debug("next line")
	if not current_line: return
	#get the id of the following line
	var next_id = current_line.get("next",null)
	#if instead of an id there's an array, it means its a list of conditional options for the dialogue to continue with
	if next_id is Array:
		#store the list in options
		var options = next_id
		#iterate the list of options and set next_id as the first option evaluated as true
		for branch in options:
			var condition_string = branch.get("condition",null)
			#if an option does not have a condition, then it's considered a fall back and considered true
			if not condition_string:
				next_id = branch.get("next",null)
				break
			var expression = Expression.new()
			expression.parse(condition_string)
			var result = expression.execute([],self)
			if result:
				next_id = branch["next"]
				break
	
	if not next_id:
		end_dialogue()
		return
		
	current_line = sequence.get(next_id, null)
	if not current_line:
		push_error("Non existant dialogue id")
	_show_current_line()
	timer.start()
func end_dialogue():
	room.current_mode = Room.Mode.GAMEPLAY
	sequence = {}
	current_line = {}
	dialogue_display.visible = false
	dialogue_display.clear()
	get_tree().paused = false
	dialogue_ended.emit()
func _input(event):
	if not room.current_mode == Room.Mode.DIALOGUE: return
	if event is InputEventKey:
		if event.pressed and event.is_action_pressed("cancel"):
			end_dialogue()
		if event.pressed and event.is_action_pressed("accept"):
			if ready_for_next_line():
				_next_line()
			elif timer.is_stopped():
				dialogue_display.show_whole_text()
func ready_for_next_line():
	var ans = true
	if not timer.is_stopped(): ans = false
	if not dialogue_display.is_whole_text_visible(): ans = false
	return ans


#functions for the condition expressions to use

func character_in_party(character_name):
	return GameState.is_character_in_party(character_name)
func get_index_in_party(character_name):
	return GameState.get_party().find(character_name)
