extends Control

@export var game_manager:GameManager

@onready var win_screen := $WinScreen
@onready var xp_indicators := %CharactersLevelup
@onready var lose_screen := $LoseScreen

@onready var leave_button := %LeaveButton
@onready var reload_button := %ReloadButton

const map_scene = preload("res://scenes/overworld/overworld.tscn")

const xp_indicator_scene = preload("res://scenes/ui/xp_gained_indicator.tscn")
func set_win_status(value:bool):
	if value:#won
		MusicPlayer.play_music(load("res://addons/Pixel_boy/theme-3b.ogg"),0)
		lose_screen.visible = false
		win_screen.visible = true
		var xp_per_character = game_manager.xp_reward/game_manager.party.size()
		for p in game_manager.party:
			var new_xp_indicator = xp_indicator_scene.instantiate()
			if !CharacterDatabase.ALL_CHARACTERS.has(p.entity_name): continue
			new_xp_indicator.leveled_up = CharacterDatabase.gain_xp(p.entity_name,xp_per_character)
			new_xp_indicator.associated_character = p.entity_name
			new_xp_indicator.xp_added = xp_per_character
			xp_indicators.add_child(new_xp_indicator)
		SaveManager.save_game(GameState.current_save_slot_index)
		leave_button.grab_focus()
	else:#lost
		MusicPlayer.play_music(load("res://addons/sfx/Retro Negative Long 12.wav"),0)
		lose_screen.visible = true
		win_screen.visible = false
		reload_button.grab_focus()
	game_manager.end_turn_buttton.visible = false
func reload_and_leave():
	SaveManager.load_game(GameState.current_save_slot_index)
	GameState.go_to_map()
func leave():
	GameState.current_level = ""
	GameState.current_enemy_battle = ""
	GameState.go_to_map()


func _on_reload_button_pressed():
	reload_and_leave()

func _on_leave_button_pressed():
	leave()
