extends State
class_name OverworldEnemyIdle

@export var path_follow:PathFollow2D
@export var movement_speed:float 
@export var vision_area:Area2D
@export var enemy:CharacterBody2D
@export var enemy_spot:Node2D
func _ready() -> void:
	vision_area.body_entered.connect(_on_body_entered_vision)
func _on_body_entered_vision(body):
	if body.is_in_group("player"):
		transitioned.emit(self, "Chasing")
func physics_update():
	path_follow.progress += movement_speed
	var distance =enemy_spot.global_position-enemy.global_position
	enemy.velocity = distance.normalized()*(sqrt(distance.length()))*10
	enemy.move_and_slide()
