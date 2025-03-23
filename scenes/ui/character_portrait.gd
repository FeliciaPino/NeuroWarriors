extends Control
class_name CharacterPortrait

@export var associated_character:String
@onready var texture_rect := $PanelContainer/TextureRect
@onready var panel := $PanelContainer

var _is_being_dragged:bool = false
var _dragging_mouse_offset:Vector2 = Vector2()
func _ready() -> void:
	print(str(self,": ",associated_character))
	var new_texture:AtlasTexture = AtlasTexture.new()
	new_texture.atlas = load("res://assets/characters/"+associated_character+".png")
	new_texture.region = Rect2(0,0,100,160)
	if texture_rect:
		texture_rect.texture = new_texture 
	else:
		print(str(self,": texutrearesct ",texture_rect))
func _start_being_dragged(mouse_offset):
	_dragging_mouse_offset = mouse_offset
	_is_being_dragged = true
	panel.modulate = Color(0,0,0,0)
func _end_being_dragged(at_position_global:Vector2):
	panel.global_position = at_position_global+_dragging_mouse_offset
	panel.modulate = Color.WHITE
	get_tree().create_tween().tween_property(panel,"position",Vector2(0,0),0.2)
	_is_being_dragged = false
func _get_drag_data(at_position: Vector2) -> Variant:
	var preview = panel.duplicate()
	var preview_control = Control.new()
	preview_control.add_child(preview)
	preview.position = -at_position
	set_drag_preview(preview_control)
	_start_being_dragged(-at_position)
	print(str(self,": dragging"))
	return self
func _can_drop_data(_pos, data):
	return data is CharacterPortrait
func _swap(character_portrait_1:CharacterPortrait,character_portrait_2:CharacterPortrait):
	var pos_1 = character_portrait_1.global_position
	var pos_2 = character_portrait_2.global_position
	
	#swap them visually
	var panel_1:PanelContainer = character_portrait_1.panel
	var panel_2:PanelContainer = character_portrait_2.panel
	panel_1.z_index += 1
	panel_2.z_index += 1
	var tween = get_tree().create_tween()
	tween.set_parallel()
	tween.tween_property(panel_1,"global_position",pos_2,0.2)
	tween.tween_property(panel_2,"global_position",pos_1,0.2)
	await tween.finished
	panel_1.z_index -= 1
	panel_2.z_index -= 1
	
	var parent_1 = character_portrait_1.get_parent()
	var index_1 = character_portrait_1.get_index()
	var parent_2 = character_portrait_2.get_parent()
	var index_2 = character_portrait_2.get_index()
	if parent_1 != parent_2:
		parent_1.remove_child(character_portrait_1)
		parent_2.remove_child(character_portrait_2)
		parent_1.add_child(character_portrait_2)
		parent_2.add_child(character_portrait_1)
	parent_1.move_child(character_portrait_2,index_1)
	parent_2.move_child(character_portrait_1,index_2)
	panel_1.position = Vector2()
	panel_2.position = Vector2()
	
func _drop_data(_pos, data):
	_swap(self,data)

func _input(event):
	if _is_being_dragged and event is InputEventMouseButton and not event.is_pressed():
		_end_being_dragged(get_viewport().get_mouse_position())
