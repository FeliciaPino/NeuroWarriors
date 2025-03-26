extends Node2D
class_name  Room
@onready var return_to_menu_button = %ReturnButton
@onready var ui := $UI
@onready var party_node = $Party
@onready var passages_node = $Passages

@onready var game_menu := $UI/GameMenu

func _ready() -> void:
	print(str(self,": arrival_passage_name: ",GameState.arrival_passage_name))
	ui.visible = true
	MusicPlayer.play_music(load("res://addons/Pixel_boy/theme-3.ogg"))
	return_to_menu_button.pressed.connect(return_to_menu)
	if not passages_node: return
	for p in passages_node.get_children():
		if p.name == GameState.arrival_passage_name:
			print(str(self, p.name, " matches ", GameState.arrival_passage_name))
			var player:OverworldCharacter = get_tree().get_first_node_in_group("player")
			if player: 
				print(str(self," player loaded"))
				player.global_position = p.global_position
			else:
				print(str(self," player not loaded"))
				GameState.global_position = p.global_position
		else:
			print(str(self,": ",p.name, " does not match ", GameState.arrival_passage_name))
	
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
	GameState.overworld_info["current_room_path"]
	get_tree().change_scene_to_packed(new_room)

	print(str(self,": toggled, now it's visibiliy is: ",game_menu.visible))
func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_E and not game_menu.menu_opened:
			print(str(self,": room opening menu"))
			game_menu.open_menu()
