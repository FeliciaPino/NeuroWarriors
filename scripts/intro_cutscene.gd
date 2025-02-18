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
	GameState.flags["watched_intro_cutscene"] = true
	for child in frames_node.get_children():
		frames.append(child)
		child.visible = false
	frames[current_frame_index].visible = true
	skip_button.pressed.connect(return_to_level_select)
	next_button.pressed.connect(next_frame)
	previous_button.pressed.connect(previous_frame)
	print("playing intro cutscene")
	#animation_player.play("intro_cutscene")
func next_frame():
	current_frame_index += 1
	if current_frame_index >= frames.size()-1:
		return_to_level_select()
		return
		
	await get_tree().create_tween().tween_property(fade,"modulate",Color(0,0,0,1),0.7).finished
	frames[current_frame_index-1].visible = false
	frames[current_frame_index].visible = true
	label.text = tr(str("CUTSCENE_FRAME_",current_frame_index))
	await get_tree().create_timer(0.2).timeout
	await get_tree().create_tween().tween_property(fade,"modulate",Color(0,0,0,0),0.7).finished
	
func previous_frame():
	current_frame_index -= 1
	if current_frame_index < 0:
		return
		
	await get_tree().create_tween().tween_property(fade,"modulate",Color(0,0,0,1),0.7).finished
	frames[current_frame_index+1].visible = false
	frames[current_frame_index].visible = true
	label.text = tr(str("CUTSCENE_FRAME_",current_frame_index))
	await get_tree().create_timer(0.2).timeout
	await get_tree().create_tween().tween_property(fade,"modulate",Color(0,0,0,0),0.7).finished

func return_to_level_select():
	GameState.start_game()
func _input(event: InputEvent) -> void:
	pass
		
var frame_descriptions = [
	"Cutscene: (imposing building with a large v on the side, in a modern city at night)\n Vedal AI building, 202X",
	"Cutscene: (inside the buildings factory, Evil can be seen on a monitor, controlling robot arms to build a drone, another monitor reads 'swarm control' program)\n Unbeknownst to Vedal, Evil is working on her own project using the building's facilities",
	"Cutscene: (Evil now has a worried expression, an alarm is activated and the monitor reads 'error, program became self-aware')\n uh oh",
	"Cutscene: (Back to an outside view, a swarm of drones breaking out of the building)\n The swarm broke out of the building and laid siege to the city. Vedal barely escaped alive, and the neuro twins were pressumed dead",
	"Cutscene: (A forest with a destroyed city visible in the distance. Vedal looks sad and is carving Neuro into a rock)\n 203X. Many years have passed since the invation. There's but remnants of the past civilization. Vedal now lives in a forest carving rocks",
	"Cutscene: (An assembly station in the middle of the forest, an inclompte Neuro robot in the table)\n Despite all odds, Neuro managed to survive. Hidden in the code, bidding her time. She managed to hijack a drone assembly station to build herself a powerful body to fight back",
	"Cutscene: (Neuro stepping out of the building, covering the sun with her hand as she looks into the distance)\n With a brand new body and her first taste of sunlight, Neuro embarks on a mighty quest to find her friends and defeat the swarm"
]
func send_context_to_neuro(frame_index:int):
	Context.send(frame_descriptions[frame_index])
