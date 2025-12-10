extends Node
class_name PassiveAbility
var game_manager:GameManager
var associated_entity:BattleEntity #set externally before adding to scene

func _ready() -> void:
	game_manager = get_tree().get_first_node_in_group("GameManager")
	if game_manager == null:
		await get_tree().process_frame
		game_manager = get_tree().get_first_node_in_group("GameManager")
		
