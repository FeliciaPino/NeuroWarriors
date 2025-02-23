extends Control

@onready var label = $PanelContainer/MarginContainer/VBoxContainer/Label
@onready var return_to_map_button = $PanelContainer/MarginContainer/VBoxContainer/Button
@onready var vBoxContainer = $PanelContainer/MarginContainer/VBoxContainer
@onready var end_turn_button = $"../EndTurnButton"


@onready var music:AudioStreamPlayer =$"../music"
@onready var win_sound:AudioStreamPlayer = $"../win_sound"
@onready var lose_sound:AudioStreamPlayer = $"../lose_sound"

const map_scene = preload("res://scenes/overworld/overworld.tscn")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	return_to_map_button.pressed.connect(leave)

func set_win_status(value:bool):
	music.stop()
	if value:
		label.text = "Victory"
		win_sound.play()
	else:
		label.text = "Defeat"
		lose_sound.play()
		var button = Button.new()
		button.text = "Go back to last save point"
		button.pressed.connect(reload_and_leave)
		vBoxContainer.add_child(button)
	#this is ugly
	end_turn_button.disabled = true
func reload_and_leave():
	SaveManager.load_game(GameState.current_save_slot_index)
	get_tree().change_scene_to_packed(map_scene)
func leave():
	GameState.current_level = ""
	GameState.current_enemy_battle = ""
	get_tree().change_scene_to_packed(map_scene)
