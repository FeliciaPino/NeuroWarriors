extends Control
@onready var frames = $frames
@onready var animation_player  = $AnimationPlayer
@onready var skip_button = $skip_button
@onready var skip_button_timer = $skip_button_timer
@onready var button_animation_player = $buttonAnimation
func _ready() -> void:
	GameState.wached_intro_cutscene = true
	for child in frames.get_children():
		child.visible = false
	skip_button.pressed.connect(return_to_level_select)
	skip_button_timer.timeout.connect(func(): button_animation_player.play_backwards("appear_button"))
	print("playing intro cutscene")
	animation_player.play("intro_cutscene")
	
func return_to_level_select():
	get_tree().change_scene_to_file("res://scenes/levels/level_select.tscn")
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and skip_button_timer.is_stopped():
		print("show button")
		button_animation_player.play("appear_button")
		skip_button_timer.start()
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
