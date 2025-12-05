extends Control
class_name SkillTree
@export var associated_character:String

@onready var camera = $Camera2D
func _ready() -> void:
	get_viewport().gui_focus_changed.connect(func(_node):follow_focus=true)
	$debugton3.grab_focus()
var follow_focus := true
var camera_momentum := Vector2.ZERO
var dragging := false
func _process(_delta):
	var focused := get_viewport().gui_get_focus_owner()
	if focused and follow_focus and focused is Control: camera.global_position = lerp(camera.global_position,focused.global_position+focused.size*0.5,0.01)
	camera.position += camera_momentum
	camera_momentum *= 0.9
	if camera_momentum.length() < 0.1: camera_momentum = Vector2.ZERO
	$debugton.text = str("press to get 6 moola (u haz ",GameState.get_tungesten_amount(),"moola)")
	$debugton2.text = str("press to level up, (",associated_character," is lvl ",GameState.characters_save_info[associated_character]["level"]," rn")
	$Label.text = str("active upgrades:",GameState.characters_save_info[associated_character]["active_upgrades"])
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		GameState.go_to_map()
	
	if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		follow_focus = false
		camera_momentum = -event.relative
func _on_debugton_pressed():
	GameState.increase_tungesten_amount(6)
func _on_debugton_2_pressed():
	var character_name = associated_character
	GameState.characters_save_info[character_name]["level"] = int(GameState.characters_save_info[character_name]["level"] + 1)
	CharacterDatabase.character_leveled_up.emit(character_name)

func _on_debugton_3_pressed():
	print_debug(str(self,": debugton pressed"))
	GameState.go_to_map()
