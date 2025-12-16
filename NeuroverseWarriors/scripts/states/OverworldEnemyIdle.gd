extends State
class_name OverworldEnemyIdle

@export var vision_area:Area2D
@export var enemy:OverworldEnemy
@export var body:CharacterBody2D
var enemy_spot:Node2D

func _ready() -> void:
	vision_area.body_entered.connect(_on_body_entered_vision)
	enemy_spot = enemy.target_spot
func _on_body_entered_vision(body_entered):
	if body_entered.is_in_group("player"):
		transitioned.emit(self, "Chasing")
func physics_update():
	if not enemy_spot:
		return
	var distance = enemy_spot.global_position-body.global_position
	body.velocity = distance.normalized()*enemy.movement_speed
	if distance.length()<30:
		body.velocity = distance*enemy.movement_speed/30
	body.move_and_slide()
