extends Node
class_name DialogueManager
signal dialogue_started
signal dialogue_ended

@onready var dialogue_display := %DialogueDisplay
@onready var timer:Timer = $Timer
@onready var room:Room = $".."
var ready_for_next_line:bool = false
var sequence = {}
var current_line = {}
#This is called by the dialogue triggers
func start_dialogue(path_to_dialogue_sequence_json:String):
	
	dialogue_started.emit()
	room.current_mode = Room.Mode.DIALOGUE
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
		print_debug("aaaaaa")
		var id = line.get("id","")
		if id != "":
			if sequence.has("id"):push_error("Duplicate dialogue id: " + id)
			sequence[id] = line
			print_debug(str("adding id:",id))
	current_line = sequence.get("start",null)
	if not current_line:
		push_error("Dialogue JSON missing start line")
	dialogue_display.visible = true
	show_current_line()
	ready_for_next_line = false
	timer.start()
	get_tree().paused = true
func show_current_line():
	print_debug(str("showing line: ",current_line["id"]))
	dialogue_display.display_line(current_line["speaker"],current_line["expression"],tr(current_line["text_key"]))
	

func next_line():
	print_debug("next line")
	if not current_line: return
	
	var next_id = current_line.get("next",null)
	if not next_id:
		end_dialogue()
		return
	current_line = sequence.get(next_id, null)
	if not current_line:
		push_error("Non existant dialogue id")
	show_current_line()
	ready_for_next_line = false
	timer.start()
func end_dialogue():
	room.current_mode = Room.Mode.GAMEPLAY
	sequence = {}
	current_line = {}
	dialogue_display.visible = false
	get_tree().paused = false
	
func _input(event):
	if not room.current_mode == Room.Mode.DIALOGUE: return
	print_debug("bwaa")
	if event is InputEventKey:
		if event.pressed and event.is_action_pressed("cancel"):
			end_dialogue()
		if event.pressed and event.is_action_pressed("accept") and ready_for_next_line:
			next_line()


func _on_timer_timeout() -> void:
	print_debug("timer timeout")
	ready_for_next_line = true
