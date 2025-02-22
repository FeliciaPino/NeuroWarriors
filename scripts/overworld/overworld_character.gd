extends CharacterBody2D
class_name OverworldCharacter

@export var camera_target:Node2D

@onready var sprite = $AnimatedSprite2D

var speed = 200
func _physics_process(delta: float) -> void:
	var direction  = Input.get_vector("left","right","up","down")
	velocity = direction*speed
	if velocity.x < 0: sprite.flip_h = true
	if velocity.x > 0: sprite.flip_h = false
	if velocity.length() > 0:
		sprite.play("moving")
	else:
		sprite.play("default")
	move_and_slide()
	
	if camera_target:
		camera_target.position = velocity/4
