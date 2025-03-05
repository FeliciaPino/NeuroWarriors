extends Control

@onready var label = $PanelContainer/MarginContainer/VBoxContainer/Label
@onready var return_to_map_button = $PanelContainer/MarginContainer/VBoxContainer/Button
@onready var vBoxContainer = $PanelContainer/MarginContainer/VBoxContainer
@onready var end_turn_button = %EndTurnButton


const map_scene = preload("res://scenes/overworld/overworld.tscn")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	return_to_map_button.pressed.connect(leave)

func set_win_status(value:bool):
	if value:
		label.text = "Victory"
		MusicPlayer.play_music(load("res://addons/Pixel_boy/theme-3b.ogg"),0)
	else:
		label.text = "Defeat"
		MusicPlayer.play_music(load("res://addons/sfx/Retro Negative Long 12.wav"),0)
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
