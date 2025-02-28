extends Node2D
const overworld_character_scene = preload("res://scenes/overworld/overworld_character.tscn")
@export var camera:Camera2D
func _ready() -> void:
	
	var party = GameState.characters_save_info["party"]
	var previous_character:OverworldCharacter = null
	var new_character:OverworldCharacter = null
	for character_name in party:
		new_character = overworld_character_scene.instantiate()
		print(str(self,": created new character:",character_name,",",new_character))
		if previous_character == null:
			camera.reparent(new_character)
			new_character.add_to_group("player")
		new_character.following_target = previous_character
		var spriteframes = load("res://assets/overworld/"+character_name+"_spriteframes.tres")
		print(str(self,": loading spriteframes ",spriteframes))
		new_character.inspector_spriteframes = spriteframes
		self.add_child(new_character)
		previous_character = new_character
		
	
	if camera:
		camera.position = Vector2()
		camera.position_smoothing_enabled = false
		await get_tree().process_frame
		camera.position_smoothing_enabled = true
	
