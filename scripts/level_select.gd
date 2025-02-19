extends Control
@onready var return_button = %ReturnButton
@onready var cutscene_button = %PlayCutsceneButton
@export var last_level:String
const main_menu_scene = preload("res://scenes/main_menu.tscn")
const cutscene = preload("res://scenes/intro_cutscene.tscn")
func _ready() -> void:
	return_button.pressed.connect(return_to_menu)
	cutscene_button.pressed.connect(get_tree().change_scene_to_packed.bind(cutscene))
	#test, remove
	var display = $TestCharactersDisplay
	display.get_child(0).visible = GameState.characters_save_info["Neuro-sama"]["unlocked"]
	display.get_child(1).visible = GameState.characters_save_info["Vedal"]["unlocked"]
	display.get_child(2).visible = GameState.characters_save_info["Evil"]["unlocked"]
	
func return_to_menu():
	SaveManager.save_game(GameState.current_save_slot_index)
	get_tree().change_scene_to_packed(main_menu_scene)
func load_level(path:String):
	BattleMaker.go_to_level(path)
