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
	get_tree().get_first_node_in_group("player").process_mode = PROCESS_MODE_DISABLED
	var fade:AnimationPlayer = get_tree().current_scene.get_node_or_null("%FadeAnimationPlayer")
	if fade:
		print(str(self)+": fading out")
		fade.play("battle_fade")
	else:
		print(str(self)+": not fading out")
	
	GameState.current_level_path = path
	
	GameState.arrival_passage_name = ""
	
	var party:Array[BattleEntity] = []
	for character_name in GameState.characters_save_info["party"]:
		if character_name == "":continue
		party.append(CharacterDatabase.get_entity_scene(character_name).instantiate())
	for p in party:
		CharacterDatabase.apply_level(p,GameState.characters_save_info[p.entity_name]["level"])
		for up_name in GameState.characters_save_info[p.entity_name]["active_upgrades"]:
			var upgrade = CharacterDatabase.get_upgrade(up_name)
			if upgrade.type == Upgrade.UpgradeType.ENTITY_MOD:
				upgrade.apply_to_entity(p)
	if fade:
		print(str(self)+": waiting for fade")
		await fade.animation_finished
	get_tree().change_scene_to_file(path)
	while get_tree().current_scene == null:
		print("awainting process secen in battlemaker")
		await get_tree().process_frame
	var game:GameManager = get_tree().current_scene
	print(str(self,": loading characters in party: ",party))
	for member in party:
		game.entity_manager.spawn_entity(member)
const battle_scene = preload("res://scenes/levels/game.tscn")
func start_battle():
	pass
	
	
	
