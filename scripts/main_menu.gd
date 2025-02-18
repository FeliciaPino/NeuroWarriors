extends Control

@onready var animation_player = $AnimationPlayer
@onready var play_button = %PlayButton
@onready var options_menu = %OptionsMenu
@onready var neuro_control_toggle = $CheckButton
@onready var return_to_main_menu_button = $SaveSlots/ReturnToMenuButton
@onready var save_slots = $SaveSlots/Slots
@onready var background = $background

@onready var om_music_slider = %MusicSlider
@onready var om_SFX_slider = %SFXSlider
func _ready() -> void:
	play_button.pressed.connect(got_to_save_slots)
	om_music_slider.value = AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Music"))
	om_SFX_slider.value = AudioServer.get_bus_volume_db(AudioServer.get_bus_index("SFX"))
	background.play("default")
	neuro_control_toggle.button_pressed = GameState.is_neuro_controlling
	
	return_to_main_menu_button.pressed.connect(animation_player.play_backwards.bind("FadeToSaveSlots"))
	
	
func got_to_save_slots():
	animation_player.play("FadeToSaveSlots")
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


func _on_check_button_toggled(toggled_on: bool) -> void:
	GameState.is_neuro_controlling = toggled_on


func _on_english_button_pressed() -> void:
	TranslationServer.set_locale("en")
	


func _on_spanish_button_pressed() -> void:
	TranslationServer.set_locale("es")
