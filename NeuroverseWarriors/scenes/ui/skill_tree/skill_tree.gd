extends Control
class_name SkillTree
@export var associated_character:String
@export var connection_line:TextureRect
@onready var camera := $Camera2D
func _ready() -> void:
	get_viewport().gui_focus_changed.connect(func(_node):follow_focus=true)
	$debugton3.grab_focus()
var follow_focus := true
var camera_momentum := Vector2.ZERO
func _process(_delta):
	var focused := get_viewport().gui_get_focus_owner()
	if follow_focus and focused:
		camera.global_position = lerp(camera.global_position,focused.global_position+focused.size*0.5,0.01)
	camera.position += camera_momentum
	camera_momentum *= 0.9
	if camera_momentum.length() < 0.1: camera_momentum = Vector2.ZERO
	camera.position.x = clamp(camera.position.x,camera.limit_left + camera.get_viewport_rect().size.x/2, camera.limit_right + camera.get_viewport_rect().size.x/2)
	camera.position.y = clamp(camera.position.y, camera.limit_top + camera.get_viewport_rect().size.y/2, camera.limit_bottom + camera.get_viewport_rect().size.y/2)
	
	$CanvasLayer/Tungesten_counter.update_displayed_value()
	$debugton.text = str("press to get 6 moola (u haz ",GameState.get_tungesten_amount(),"moola)")
	$debugton2.text = str("press to level up, (",associated_character," is lvl ",GameState.characters_save_info[associated_character]["level"]," rn")
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_leave()
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		var focused = get_viewport().gui_get_focus_owner()
		if focused and focused is SkillTreeNode:
			if not focused.get_rect().has_point(get_global_mouse_position()):
				focused.hide_info()
				follow_focus = false
			
	if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		camera_momentum = -event.relative
		follow_focus = false
func _leave():
	$CanvasLayer/Fade.visible = true
	await create_tween().tween_property($CanvasLayer/Fade,"modulate:a",1,1).finished
	GameState.go_to_map()
func _on_debugton_pressed():
	GameState.increase_tungesten_amount(6)
func _on_debugton_2_pressed():
	var character_name = associated_character
	GameState.characters_save_info[character_name]["level"] = int(GameState.characters_save_info[character_name]["level"] + 1)
	CharacterDatabase.character_leveled_up.emit(character_name)

func _on_debugton_3_pressed():
	print_debug(str(self,": debugton pressed"))
	_leave()
