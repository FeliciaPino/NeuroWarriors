extends Node


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
func _figure_out_enemies():
	pass
func _figure_out_party():
	pass
func _figure_out_background():
	pass
func go_to_level(path:String):
	GameState.current_level_path = path
	var party:Array[BattleEntity] = []
	for character_name in GameState.characters_save_info["party"]:
		party.append(CharacterDatabase.get_entity_scene(character_name).instantiate())
	get_tree().change_scene_to_file(path)
	while get_tree().current_scene == null:
		await get_tree().process_frame
	var game:GameManager = get_tree().current_scene
	for member in party:
		game.entity_manager.spawn_entity(member)
const battle_scene = preload("res://scenes/levels/game.tscn")
func start_battle():
	pass
	
	
	
