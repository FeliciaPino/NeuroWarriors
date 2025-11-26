extends Control
@onready var animation_player  = $AnimationPlayer
@onready var skip_button = $leave
func _ready() -> void:
	print_debug("credits ready")
	MusicPlayer.play_music(load("res://addons/Pixel_boy/theme-4.ogg"))

	GameState.flags["watched_credits"] = true
	skip_button.visible = false
	skip_button.pressed.connect(return_to_menu)
	animation_player.play("credits_anim")
	animation_player.seek(0)
	SaveManager.save_game(GameState.current_save_slot_index)
	
func return_to_menu():
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		skip_button.visible = true
