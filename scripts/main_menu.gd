extends Control

@onready var animation_player = $AnimationPlayer
@onready var play_button = %PlayButton
@onready var options_menu = %OptionsMenu
@onready var return_to_main_menu_button = $SaveSlots/ReturnToMenuButton
@onready var save_slots = $SaveSlots/Slots
@onready var background = $background

@onready var om_music_slider = %MusicSlider
@onready var om_SFX_slider = %SFXSlider
func _ready() -> void:
	MusicPlayer.play_music(load("res://assets/audio/music/4.ogg"))
	play_button.pressed.connect(got_to_save_slots)
	play_button.grab_focus()
	options_menu.visible = false
	om_music_slider.value = AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Music"))
	om_SFX_slider.value = AudioServer.get_bus_volume_db(AudioServer.get_bus_index("SFX"))
	background.play("default")
	
	return_to_main_menu_button.pressed.connect(animation_player.play_backwards.bind("FadeToSaveSlots"))
	
	
func got_to_save_slots():
	animation_player.play("FadeToSaveSlots")
	save_slots.get_child(0).load_button.grab_focus()
	for slot in save_slots.get_children():
		slot.update_text()
	
func play(save_slot_index:int):
	SaveManager.load_game(save_slot_index)
	GameState.current_save_slot_index = save_slot_index
	if GameState.flags["watched_intro_cutscene"]:
		get_tree().change_scene_to_file("res://scenes/levels/level_select.tscn")
	else:
		get_tree().change_scene_to_file("res://scenes/intro_cutscene.tscn")



func _on_options_button_toggled(toggled_on: bool) -> void:
	options_menu.visible = toggled_on

func _on_music_volume_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"),value)

func _on_sound_effects_volume_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"),value)


func _on_exit_button_pressed() -> void:
	get_tree().quit()


func _on_english_button_pressed() -> void:
	TranslationServer.set_locale("en")
	


func _on_spanish_button_pressed() -> void:
	TranslationServer.set_locale("es")
