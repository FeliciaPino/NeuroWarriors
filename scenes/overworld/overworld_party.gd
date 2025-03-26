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
		else:
			new_character.global_position = previous_character.global_position
		new_character.following_target = previous_character
		var spriteframes = load("res://assets/overworld/"+character_name+"_spriteframes.tres")
		new_character.inspector_spriteframes = spriteframes
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
	var party = GameState.get_party()
	while get_child_count()-1 > party.size():
		print(str(self,": child count of ",get_child_count()," means that there's too many chars in world, deleting ",get_child(-1)))
		get_child(-1).queue_free()
		await get_tree().process_frame
	print(str(self,": iterating through ",party.size()," characters in party"))
	var i:int = 0
	while i<party.size():
		if get_child_count() > i+1:
			print(str(self,": since ",get_child_count()," is more than ",i+2," we can just re-skin ",get_child(i+1)))
			get_child(i+1).update_sprite_frames_from_character_name(party[i])
			i += 1
			continue
		print(str(self,": not enough current chars, creating a new one to represent ",party[i]))
		var new_char:OverworldCharacter = overworld_character_scene.instantiate()
		new_char.inspector_spriteframes = load("res://assets/overworld/"+party[i]+"_spriteframes.tres")
		if i>0:
			new_char.following_target = get_child(i)
		add_child(new_char)
		i += 1
	if get_child_count()<=1: return
	if not get_child(1).is_in_group("player"):
		get_child(1).add_to_group("player")
		
