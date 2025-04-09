extends Control
class_name SkillTree
@export var associated_character:String

func _process(delta):
	$debugton.text = str("press to get 2 moola (u haz ",GameState.get_tungesten_amount(),"moola)")
	$debugton2.text = str("press to level up, (",associated_character," is lvl ",GameState.characters_save_info[associated_character]["level"]," rn")
	$Label.text = str("active upgrades:",GameState.characters_save_info[associated_character]["active_upgrades"])
func _on_debugton_pressed():
	GameState.increase_tungesten_amount(2)
func _on_debugton_2_pressed():
	var character_name = associated_character
	GameState.characters_save_info[character_name]["level"] = int(GameState.characters_save_info[character_name]["level"] + 1)
	CharacterDatabase.character_leveled_up.emit(character_name)

func _on_debugton_3_pressed():
	print(str(self,": debugton pressed"))
	GameState.go_to_map()
