extends Node2D
class_name OverworldEnemy

@export var level_path:String
@export var id:String
@export var target_spot:Node2D
@export var movement_speed:float
@export var enemy_respawns:bool = false
var global_id:String

@onready var enemy_body = $Body
@onready var sprite = $Body/Sprite

func _ready() -> void:
	visible = false
	global_id = get_tree().current_scene.name+"_"+id
	if enemy_respawns and GameState.arrival_passage_name != "":
		GameState.remove_overworld_enemy_defeated(global_id)
	if GameState.is_overworld_enemy_defeated(global_id):
		queue_free()
	else:
		process_mode = PROCESS_MODE_DISABLED
		await get_tree().create_timer(0.3)#grace time of 300ms
		process_mode = PROCESS_MODE_INHERIT
		visible = true
	if GameState.arrival_passage_name=="":
		
		pass 

func encounter():
	GameState.current_level = ""
	GameState.current_enemy_battle = global_id
	BattleMaker.go_to_level(level_path)
func disable():
	process_mode = PROCESS_MODE_DISABLED
func _on_encounter_collider_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		call_deferred("encounter")
		call_deferred("disable")
		print(str(self,": player collided with enemy:",global_id))
