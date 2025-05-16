extends Node
class_name DialogueManager
signal dialogue_started
signal dialogue_ended

#This is called by the dialogue triggers
func start_dialogue(path_to_dialogue_sequence_json:String):
	dialogue_started.emit()
	var dialogue_sequence = FileAccess.get_file_as_string(path_to_dialogue_sequence_json)
	%DialogueDisplay.visible = true
	%DialogueDisplay.label.text = dialogue_sequence

func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and event.is_action_pressed("cancel"):
			%DialogueDisplay.visible = false
