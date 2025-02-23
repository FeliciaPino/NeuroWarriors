extends Node2D
@onready var return_to_menu_button = %ReturnButton

func _ready() -> void:
	return_to_menu_button.pressed.connect(return_to_menu)
const main_menu_scene = preload("res://scenes/main_menu.tscn")
func return_to_menu():
	SaveManager.save_game(GameState.current_save_slot_index)
	get_tree().change_scene_to_packed(main_menu_scene)
