extends Node2D
class_name OverworldEnemy

@export var level_path:String
@export var id:String
@export var target_spot:Node2D
@export var movement_speed:float

@onready var enemy_body = $Body
@onready var sprite = $Body/Sprite

func _ready() -> void:
	visible = false
	if GameState.is_overworld_enemy_defeated(id):
		queue_free()
	else:
		visible = true

func _process(delta: float) -> void:
	if enemy_body.velocity.x < 0: sprite.flip_h = true
	if enemy_body.velocity.x > 0: sprite.flip_h = false

func encounter():
	GameState.current_level = ""
	GameState.current_enemy_battle = id
	BattleMaker.go_to_level(level_path)

func _on_encounter_collider_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		call_deferred("encounter")
