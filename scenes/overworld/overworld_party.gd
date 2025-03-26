extends Node2D
const overworld_character_scene = preload("res://scenes/overworld/overworld_character.tscn")
@export var camera:Camera2D

#the first child of this node is the camere, the following children are the overworld characters


func _ready() -> void:
	
	var party = GameState.get_party()
	var previous_character:OverworldCharacter = null
	var new_character:OverworldCharacter = null
	for character_name in party:
		if character_name == "": continue
		new_character = overworld_character_scene.instantiate()
		print(str(self,": created new character:",character_name,",",new_character))
		if previous_character == null:
			camera.reparent(new_character)
			new_character.add_to_group("player")
			new_character.global_position = GameState.get_player_map_position()
		else:
			new_character.global_position = previous_character.global_position+Vector2(0,-10)
		new_character.following_target = previous_character
		new_character.associated_character = character_name
		self.add_child(new_character)
		previous_character = new_character
	if camera:
		camera.position = Vector2()
		camera.position_smoothing_enabled = false
		await get_tree().process_frame
		camera.position_smoothing_enabled = true
#makes the overworld characters reflect the current party stored in gamestate
func update_characters():
	
	#this whole function feels pretty messy
	print(str(self,": updating characters"))
	var party:Array = GameState.get_party()
	#there has to be a better way of getting rid of the empty character names
	party.erase("")
	party.erase("")
	party.erase("")
	var characters:Array[OverworldCharacter]
	print(str(self,": party:",party))
	for c in get_children():
		if c is OverworldCharacter:
			characters.append(c)
	print(str(self,": characters in world currently:",characters))
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
			add_child(char)
		updated_characters.append(char)
		print(str(self,"updated characters:",updated_characters))
		if i>0:
			char.following_target = updated_characters[i-1]
	print(str(self, ": old character count: ",characters.size()," party count: ",party.size()))
	for i in range(updated_characters.size(),characters.size()):
		characters[i].queue_free()
