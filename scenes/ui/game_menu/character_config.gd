extends Control


const neuro_skill_tree_scene = preload("res://scenes/ui/skill_tree/skill_tree.tscn")
func _on_debugton_pressed():
	$"../..".close_menu()
	GameState.arrival_passage_name = ""
	get_tree().change_scene_to_packed(neuro_skill_tree_scene)
