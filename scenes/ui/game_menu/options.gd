extends Control

@onready var gameMenu = $"../.."
const main_menu_scene = preload("res://scenes/main_menu.tscn")
func return_to_menu():
	gameMenu.close_menu()
	get_tree().change_scene_to_packed(main_menu_scene)
	


func _on_return_to_menu_pressed() -> void:
	return_to_menu()
