extends Node2D
class_name  Room
@onready var return_to_menu_button = %ReturnButton
@onready var ui := $UI
@onready var party_node = $Party
@onready var passages_node = $Passages

@onready var game_menu := $UI/GameMenu
enum Mode {
	GAMEPLAY,
	MENU,
	DIALOGUE
}
var current_mode = Mode.GAMEPLAY
func _ready() -> void:
	print_debug(str(self,": arrival_passage_name: ",GameState.arrival_passage_name))
	ui.visible = true
	MusicPlayer.play_music(load("res://addons/Pixel_boy/theme-3.ogg"))
	return_to_menu_button.pressed.connect(return_to_menu)
	if not passages_node: return
	for p in passages_node.get_children():
		if p.name == GameState.arrival_passage_name:
			GameState.set_player_map_position(p.global_position)
			SaveManager.save_game(GameState.current_save_slot_index)
			break

	party_node.update_characters()
	game_menu.menu_has_just_closed.connect(party_node.update_characters)
	
const main_menu_scene = preload("res://scenes/main_menu.tscn")
@onready var fade = %FadeAnimationPlayer
func return_to_menu():
	get_tree().change_scene_to_packed(main_menu_scene)

func fade_to_room(new_room:PackedScene, arrival_passage_name:String):
	get_tree().get_first_node_in_group("player").process_mode = PROCESS_MODE_DISABLED
	fade.play("fade_out")
	await fade.animation_finished
	GameState.set_player_map_position(Vector2())
	GameState.arrival_passage_name = arrival_passage_name
	GameState.current_room_scene = new_room
	get_tree().change_scene_to_packed(new_room)
func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_E and not game_menu.menu_opened and current_mode == Mode.GAMEPLAY:
			print_debug(str(self,": room opening menu"))
			game_menu.open_menu()
