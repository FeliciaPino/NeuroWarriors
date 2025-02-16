extends Control
@onready var return_button = $return
@export var last_level:String
const main_menu_scene = preload("res://scenes/main_menu.tscn")
func _ready() -> void:
	return_button.pressed.connect(func(): get_tree().change_scene_to_packed(main_menu_scene))
func load_level(path:String):
	get_tree().change_scene_to_file(path)
