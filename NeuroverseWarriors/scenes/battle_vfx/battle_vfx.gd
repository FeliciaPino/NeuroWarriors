extends Node2D
class_name BattleVFX
@onready var animation_player := $AnimationPlayer
@onready var timer := $Timer
@onready var delay_timer := $Delay
@export var duration := 0.0 #0 means it just plays the animation once, or forever if it loops
@export var delay := 0.0 #How long to wait before starting. 
@export var speed_scale := 1.0

func _ready() -> void:
	animation_player.speed_scale = speed_scale
	if delay > 0.0:
		animation_player.process_mode = Node.PROCESS_MODE_DISABLED
		delay_timer.wait_time = delay
		delay_timer.start()
		await delay_timer.timeout
		animation_player.process_mode = Node.PROCESS_MODE_INHERIT
	if duration > 0.0:
		timer.wait_time = duration
		timer.start()
		timer.timeout.connect(queue_free)
	else:
		animation_player.animation_finished.connect(func(_anim_name):queue_free())
