extends Node
class_name StateMachine

@export var initial_state:State

var current_state:State
var states:Dictionary = {}

func _ready() -> void:
	for child in get_children():
		if child is State:
			states[child.name] = child
			child.transitioned.connect(_on_child_transition)
	if initial_state:
		initial_state.enter()
		current_state = initial_state
func _process(_delta: float) -> void:
	if current_state:
		current_state.update()
func _physics_process(_delta: float) -> void:
	if current_state:
		current_state.physics_update()
func _on_child_transition(state, new_state_name):
	if state != current_state: return
	var new_state = states[new_state_name]
	if not new_state: return
	if current_state:
		current_state.exit()
	new_state.enter()
	current_state = new_state
	
