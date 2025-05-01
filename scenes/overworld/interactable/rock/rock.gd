extends Node2D
@export var sprite:Sprite2D
@export var interactable_component:InteractableComponent
func _ready() -> void:
	interactable_component.interacted.connect(_on_player_interaction)
func _on_player_interaction():
	var movement:Vector2 = Vector2()
	var player:OverworldCharacter = get_tree().get_first_node_in_group("player")
	var dy:int = player.global_position.y - global_position.y
	var dx:int = player.global_position.x - global_position.x
	if dy < dx and dy < -dx: movement = Vector2(0,32) #up quadrant
	if dy > dx and dy > -dx: movement = Vector2(0,-32) #down quadrant
	if dy > dx and dy < -dx: movement = Vector2(32,0) #left quadrant
	if dy < dx and dy > -dx: movement = Vector2(-32,0) #right quadrant
	global_position += movement
	sprite.position = -movement
	get_tree().create_tween().tween_property(sprite,"position",Vector2(),0.15)
	
