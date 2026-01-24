extends Node2D
const overworld_character_scene = preload("res://scenes/overworld/overworld_character.tscn")
@export var camera:Camera2D

@onready var animation_follow_targets_node = $AnimationFollowTargets
var is_being_controlled_by_animation:bool=false #For when animations from like cutscenes want to move the characters around




#the first child of this node is the camere, the following children are the overworld characters

func _ready() -> void:
	pass
func _process(_delta: float) -> void:
	var player:OverworldCharacter = get_tree().get_first_node_in_group("player")
	if player:
		camera.position = lerp(camera.position,player.position+player.velocity*0.67,0.9*_delta)
func get_characters() -> Array[OverworldCharacter]:
	var characters:Array[OverworldCharacter]
	for c in get_children():
		if c is OverworldCharacter:
			characters.append(c)
	return characters
#makes the overworld characters reflect the current party stored in gamestate
func update_characters():
	var party:Array = GameState.get_party()
	var characters:Array[OverworldCharacter] = get_characters()
	var updated_characters:Array[OverworldCharacter]
	for i in range(party.size()):
		var chara:OverworldCharacter
		if i < characters.size():
			chara = characters[i]
			chara.update_sprite_frames_from_character_name(party[i])
		else:
			chara = overworld_character_scene.instantiate()
			chara.associated_character = party[i]
			if i>0:
				chara.global_position = updated_characters[i-1].global_position + Vector2(0,-15)
			else:
				chara.global_position = GameState.get_player_map_position()
			add_child(chara)
		updated_characters.append(chara)
		if i>0:
			chara.following_target = updated_characters[i-1]
		else:
			chara.following_target = null
		chara.follow_distance = 25 #i think that's about a good distance for characters to follow each other
	for i in range(updated_characters.size(),characters.size()):
		characters[i].queue_free()
	if updated_characters.size()>0:
		updated_characters[0].add_to_group("player")
		camera.global_position = updated_characters[0].global_position
	for i in range(1,updated_characters.size()):
		updated_characters[i].remove_from_group("player")
	
func start_being_controlled_by_animation():
	if is_being_controlled_by_animation: return
	is_being_controlled_by_animation = true
	var characters:Array[OverworldCharacter] = get_characters()
	for i in range(min(characters.size(),animation_follow_targets_node.get_child_count())):
		characters[i].following_target = animation_follow_targets_node.get_child(i)
		characters[i].follow_distance = 0.1
func end_being_controlled_by_animation():
	if !is_being_controlled_by_animation: return
	is_being_controlled_by_animation = false
	update_characters()
