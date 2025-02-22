extends State
class_name  OverworldEnemyChase

@export var speed:float
@export var enemy:CharacterBody2D
@export var timer:Timer
var player:CharacterBody2D
func _ready() -> void:
	timer.timeout.connect(transitioned.emit.bind(self, "Idle"))

func enter():
	player = get_tree().get_first_node_in_group("player")
	timer.start()
	
func physics_update():
	var direction_of_the_player = (player.global_position-enemy.global_position).normalized()
	enemy.velocity = direction_of_the_player*speed
	enemy.move_and_slide()
	
