extends Control
@onready var frames_node = $frames
@onready var skip_button = %SkipButton
@onready var next_button = %NextButton
@onready var previous_button = %PreviousButton

var current_frame_index = 0
@onready var fade:Sprite2D = $Fade
@onready var label = %Label
var frames:Array[Sprite2D] = []
const level_select_scene = preload("res://scenes/levels/level_select.tscn")
func _ready() -> void:
	MusicPlayer.play_music(load("res://addons/Pixel_boy/theme-4.ogg"))
	GameState.flags["watched_intro_cutscene"] = true
	for child in frames_node.get_children():
		frames.append(child)
		child.visible = false
	frames[current_frame_index].visible = true
	skip_button.pressed.connect(return_to_level_select)
	next_button.pressed.connect(next_frame)
	next_button.grab_focus()
	previous_button.pressed.connect(previous_frame)
	print_debug("playing intro cutscene")
	fade.visible = true
	get_tree().create_tween().tween_property(fade,"modulate",Color(0,0,0,0),0.6)
func next_frame():
	current_frame_index += 1
	if current_frame_index >= frames.size():
		return_to_level_select()
		return
		
	await get_tree().create_tween().tween_property(fade,"modulate",Color(0,0,0,1),0.6).finished
	frames[current_frame_index-1].visible = false
	frames[current_frame_index].visible = true
	label.text = tr(str("CUTSCENE_FRAME_",current_frame_index))
	await get_tree().create_timer(0.2).timeout
	await get_tree().create_tween().tween_property(fade,"modulate",Color(0,0,0,0),0.6).finished
	
func previous_frame():
	current_frame_index -= 1
	if current_frame_index < 0:
		current_frame_index = 0
		return
		
	await get_tree().create_tween().tween_property(fade,"modulate",Color(0,0,0,1),0.6).finished
	#TODO: fix this, if the button is spammed it doesn't make the in-between frames invisible.
	frames[current_frame_index+1].visible = false
	frames[current_frame_index].visible = true
	label.text = tr(str("CUTSCENE_FRAME_",current_frame_index))
	await get_tree().create_timer(0.2).timeout
	await get_tree().create_tween().tween_property(fade,"modulate",Color(0,0,0,0),0.6).finished

func return_to_level_select():
	await get_tree().create_tween().tween_property(fade,"modulate",Color(0,0,0,1),0.6).finished 
	GameState.start_game()
func _input(_event: InputEvent) -> void:
	pass
