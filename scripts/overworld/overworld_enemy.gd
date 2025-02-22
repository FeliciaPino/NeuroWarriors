extends Path2D
class_name OverworldEnemy

@export var level_path:String

@onready var enemy =$Enemy
@onready var sprite = $Enemy/Sprite
func _process(delta: float) -> void:
	if enemy.velocity.x < 0: sprite.flip_h = true
	if enemy.velocity.x > 0: sprite.flip_h = false

func encounter():
	BattleMaker.go_to_level(level_path)

func _on_encounter_collider_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		call_deferred("encounter")
