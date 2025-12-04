extends State
class_name  OverworldEnemyChase
@export var enemy:OverworldEnemy
@export var body:CharacterBody2D
@export var chase_speed_multiplier:float
@export var timer:Timer
var player:CharacterBody2D
func _ready() -> void:
	timer.timeout.connect(transitioned.emit.bind(self, "Idle"))

func enter():
	player = get_tree().get_first_node_in_group("player")
	timer.start()
	
func physics_update():
	if player:
		var direction_of_the_player = (player.global_position-body.global_position).normalized()
		body.velocity = direction_of_the_player*enemy.movement_speed
	body.move_and_slide()
	
