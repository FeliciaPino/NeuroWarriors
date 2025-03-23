extends Control
class_name CharacterPortrait

@export var associated_character:String
@onready var texture_rect := $PanelContainer/VBoxContainer/TextureRect
@onready var panel := $PanelContainer
@onready var buttons_container := $Buttons
var is_buttons_open:bool = false
@onready var button_move_left := $Buttons/MoveLeft
@onready var button_add_to_party := $Buttons/Add
@onready var button_remove_from_party := $Buttons/Remove
@onready var button_move_right := $Buttons/MoveRight
@onready var animation_player := $AnimationPlayer
var _is_being_dragged:bool = false
var _dragging_mouse_offset:Vector2 = Vector2()
func _ready() -> void:
	print(str(self,": ",associated_character))
	var new_texture:AtlasTexture = AtlasTexture.new()
	new_texture.atlas = load("res://assets/characters/"+associated_character+".png")
	new_texture.region = Rect2(0,0,100,160)
	if texture_rect:
		texture_rect.texture = new_texture 
	button_move_left.pressed.connect(_any_button_pressed)
	button_add_to_party.pressed.connect(_any_button_pressed)
	button_remove_from_party.pressed.connect(_any_button_pressed)
	button_move_right.pressed.connect(_any_button_pressed)
	
func _process(_delta: float) -> void:
	#if someone else has focus close the buttons
	var focus_owner = get_viewport().gui_get_focus_owner()
	if focus_owner:
		if not self.is_ancestor_of(focus_owner):
			_close_buttons()
func _any_button_pressed():
	$pop.play()
	
var in_party:bool = false

func update_buttons():
	in_party = GameState.is_character_in_party(associated_character)
	button_move_left.visible = in_party
	button_move_right.visible = in_party
	button_remove_from_party.visible = in_party
	button_add_to_party.visible = not in_party
	
	
func _open_buttons():
	if is_buttons_open:return
	update_buttons()
	is_buttons_open = true
	$buttons_up.play()
	buttons_container.visible = true
	buttons_container.position = Vector2(10,140)
	var tween = get_tree().create_tween()
	tween.tween_property(buttons_container,"position",Vector2(10,170),0.05)
	if in_party:
		button_remove_from_party.grab_focus()
	else:
		button_add_to_party.grab_focus()
func _close_buttons():
	if not is_buttons_open: return
	is_buttons_open = false
	buttons_container.visible = false
	
func _start_being_dragged(mouse_offset):
	_dragging_mouse_offset = mouse_offset
	_is_being_dragged = true
	panel.modulate = Color(0,0,0,0)
	
func _end_being_dragged(at_position_global:Vector2):
	$woosh.play()
	panel.global_position = at_position_global+_dragging_mouse_offset
	panel.modulate = Color.WHITE
	_is_being_dragged = false
	panel.z_index += 3
	var tween:Tween = get_tree().create_tween()
	tween.tween_property(panel,"position",Vector2(-5,-5),0.15).set_ease(Tween.EASE_IN)
	await tween.finished
	panel.z_index -= 3
func _get_drag_data(at_position: Vector2) -> Variant:
	var preview = panel.duplicate()
	var preview_control = Control.new()
	preview_control.add_child(preview)
	preview_control.z_index = panel.z_index+3
	preview_control.scale = Vector2(1.05,1.05)
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
	panel_1.z_index += 3
	panel_2.z_index += 3
	var tween = get_tree().create_tween()
	tween.set_parallel()
	tween.tween_property(panel_1,"global_position",pos_2-Vector2(5,5),0.15)
	tween.tween_property(panel_2,"global_position",pos_1-Vector2(5,5),0.15)
	await tween.finished
	panel_1.z_index -= 3
	panel_2.z_index -= 3
	
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
	panel_1.position = Vector2(-5,-5)
	panel_2.position = Vector2(-5,-5)
	
func _drop_data(_pos, data):
	_swap(self,data)
	data.grab_focus()

func _input(event):
	if _is_being_dragged and event is InputEventMouseButton and not event.is_pressed():
		_end_being_dragged(get_viewport().get_mouse_position())
		


func _on_mouse_entered() -> void:
	grab_focus()
	
func _on_focus_entered() -> void:
	$focus.play()
	animation_player.play("focus")

func _on_button_up() -> void:
	_open_buttons()

func _on_move_left_pressed() -> void:
	var other:CharacterPortrait = get_parent().get_child(get_index()-1)
	_swap(self, other)

func _on_move_right_pressed() -> void:
	var other:CharacterPortrait
	if get_index() >= get_parent().get_child_count()-1:
		other = get_parent().get_child(0)
	else:
		other = get_parent().get_child(get_index()+1)
	_swap(self, other)
