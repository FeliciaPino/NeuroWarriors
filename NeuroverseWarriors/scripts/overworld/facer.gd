extends Node
@export var body:CharacterBody2D
@export var sprite:AnimatedSprite2D
var facing:String = "s"
func _process(delta: float) -> void:
	if body.velocity.length() > 1:
		if abs(body.velocity.x) > abs(body.velocity.y):
			facing = "e" if body.velocity.x > 0 else "w"
		else:
			facing = "s" if body.velocity.y > 0 else "n"
		sprite.play("moving_"+facing)
	else:
		sprite.play("idle_"+facing)
