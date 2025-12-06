extends Node2D
const overworld_character_scene = preload("res://scenes/overworld/overworld_character.tscn")
@export var camera:Camera2D

#the first child of this node is the camere, the following children are the overworld characters


func _ready() -> void:
	pass
#makes the overworld characters reflect the current party stored in gamestate
func update_characters():
	#this whole function feels pretty messy
	print_debug(str(self,": updating characters"))
	var party:Array = GameState.get_party()
	var characters:Array[OverworldCharacter]
	print_debug(str(self,": party:",party))
	for c in get_children():
		if c is OverworldCharacter:
			characters.append(c)
	print_debug(str(self,": characters in world currently:",characters))
	var updated_characters:Array[OverworldCharacter]
	for i in range(party.size()):
		var char:OverworldCharacter
		if i < characters.size():
			char = characters[i]
			char.update_sprite_frames_from_character_name(party[i])
		else:
			char = overworld_character_scene.instantiate()
			char.associated_character = party[i]
			if i>0:
				char.global_position = updated_characters[i-1].global_position + Vector2(0,-10)
			else:
				char.global_position = GameState.get_player_map_position()
			add_child(char)
		updated_characters.append(char)
		print_debug(str(self,"updated characters:",updated_characters))
		if i>0:
			char.following_target = updated_characters[i-1]
	print_debug(str(self, ": old character count: ",characters.size()," party count: ",party.size()))
	camera.reparent(self)
	var old_camera_global_position = camera.global_position
	for i in range(updated_characters.size(),characters.size()):
		characters[i].queue_free()
	if updated_characters.size()>0:
		updated_characters[0].add_to_group("player")
		camera.reparent(updated_characters[0])
		camera.position = Vector2()
	else:
		camera.global_position = old_camera_global_position
	camera.position_smoothing_enabled = false
	for i in range(1,updated_characters.size()):
		updated_characters[i].remove_from_group("player")
	await get_tree().process_frame
	#await get_tree().process_frame
	camera.position_smoothing_enabled = true
