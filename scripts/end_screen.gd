extends Control

@onready var label = $PanelContainer/MarginContainer/VBoxContainer/Label
@onready var vBoxContainer = $PanelContainer/MarginContainer/VBoxContainer
@onready var end_turn_button = %EndTurnButton


const map_scene = preload("res://scenes/overworld/overworld.tscn")

func set_win_status(value:bool):
	if value:
		label.text = tr("BATTLE_VICTORY")
		MusicPlayer.play_music(load("res://addons/Pixel_boy/theme-3b.ogg"),0)
		var button = Button.new()
		button.text = tr("BATTLE_RETURN_TO_MAP")
		button.pressed.connect(reload_and_leave)
		vBoxContainer.add_child(button)
	else:
		label.text = tr("BATTLE_DEFEAT")
		MusicPlayer.play_music(load("res://addons/sfx/Retro Negative Long 12.wav"),0)
		var button = Button.new()
		button.text = tr("BATTLE_RELOAD")
		button.pressed.connect(reload_and_leave)
		vBoxContainer.add_child(button)
	#this is ugly
	end_turn_button.disabled = true
func reload_and_leave():
	SaveManager.load_game(GameState.current_save_slot_index)
	GameState.go_to_map()
func leave():
	GameState.current_level = ""
	GameState.current_enemy_battle = ""
	get_tree().change_scene_to_packed(map_scene)
