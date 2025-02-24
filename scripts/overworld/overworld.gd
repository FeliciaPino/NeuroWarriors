extends Node2D
@onready var return_to_menu_button = %ReturnButton

func _ready() -> void:
	MusicPlayer.play_music(load("res://addons/Pixel_boy/theme-3.ogg"))
	return_to_menu_button.pressed.connect(return_to_menu)
const main_menu_scene = preload("res://scenes/main_menu.tscn")
@onready var fade = %FadeAnimationPlayer
func return_to_menu():
	SaveManager.save_game(GameState.current_save_slot_index)
	get_tree().change_scene_to_packed(main_menu_scene)
