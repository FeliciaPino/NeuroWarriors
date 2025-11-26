extends Node2D
@onready var evil_sprite := $AnimatedSprite2D
@onready var arm_ik_target := $"AssemblyArm/IK target"
@onready var assembly_points_node := $"Assembly Points"
@onready var entity_manager := $"../../Entity_manager"
@onready var game_manager = $"../.."
@onready var animation_player := $AssemblyArm/AnimationPlayer
@onready var timer := $Timer
@export var sfx:AudioStreamPlayer
var last_evil_sprite_frame:int = 4
const evil_character_scene = preload("res://scenes/characters/evil.tscn")
func _add_evil():
	sfx.playing = true
	var evil_entity:BattleEntity = evil_character_scene.instantiate()
	evil_entity.global_position = evil_sprite.global_position
	entity_manager.spawn_entity(evil_entity,true)	

func _ready() -> void:
	timer.start()
var working = false
func _on_timer_timeout() -> void:
	if not working:
		working = true
		var point = assembly_points_node.get_children().pick_random()
		get_tree().create_tween().tween_property(arm_ik_target, "global_position", point.global_position, 0.3)
		animation_player.play("start_working")
	else:
		working = false
		get_tree().create_tween().tween_property(arm_ik_target,"global_position",assembly_points_node.global_position, 0.3)
		animation_player.play("RESET")
const assembly_points_removal_order = ["","Knee","LeftArm","RightArm","Face"]
func _on_game_player_turn_ended() -> void:
	if evil_sprite.frame == last_evil_sprite_frame: return
	if game_manager.turn_count%2:return
	evil_sprite.frame += 1
	for c in assembly_points_node.get_children():
		if c.name == assembly_points_removal_order[evil_sprite.frame]:
			c.queue_free()
	if evil_sprite.frame == last_evil_sprite_frame:
		_add_evil()
		timer.stop()
		get_tree().create_tween().tween_property(arm_ik_target,"global_position",assembly_points_node.global_position, 0.3)
		animation_player.play("RESET")
	
