extends CharacterBody2D
class_name OverworldCharacter

@export var camera:Camera2D
@export var speed = 200

@onready var sprite = $AnimatedSprite2D


func _ready() -> void:
	global_position = GameState.get_player_map_position()
	camera.global_position = global_position
	await get_tree().process_frame
	camera.position_smoothing_enabled = true
	
func _physics_process(delta: float) -> void:
	GameState.set_player_map_position(global_position)
	var direction  = Input.get_vector("left","right","up","down")
	velocity = direction*speed
	if velocity.x < 0: sprite.flip_h = true
	if velocity.x > 0: sprite.flip_h = false
	if velocity.length() > 0:
		sprite.play("moving")
	else:
		sprite.play("default")
	move_and_slide()
	
