extends Node2D

class_name Passage

@export var collision_area:Area2D
@export var scene_path:String
@export var arriving_passage_name:String
var room:Room
var scene:PackedScene
# Called when the node enters the scene tree for the first time.
func _ready():
	
	print(str(self,"this passage is in ",global_position))
	if scene_path:
		scene = load(scene_path)
	if collision_area:
		collision_area.body_entered.connect(_on_area_body_entered)
	
	if get_tree().current_scene is Room:
		room = get_tree().current_scene
func _on_area_body_entered(body:Node2D):
	print(str(self,"collided with something"))
	if body.is_in_group("player"):
		print(str(self,": collided with player"))
		room.fade_to_room(scene, arriving_passage_name)
