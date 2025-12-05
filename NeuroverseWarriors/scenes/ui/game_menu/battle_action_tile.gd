extends Control
class_name BattleActionTile
@onready var panel := $PanelContainer
@onready var hole := $Hole
@onready var animation_player := $AnimationPlayer
@onready var icon = $PanelContainer/TextureRect
@onready var name_label = $PanelContainer/TextureRect/NameLabel
signal swaped
var selected:bool = false
var associated_battle_action:String
func _ready() -> void:
	set_associated_battle_action(associated_battle_action)
func set_associated_battle_action(value:String):
	associated_battle_action = value
	
	if value == "":
		panel.visible = false
		if !hole.visible: visible = false
		return
	else:
		visible = true
		panel.visible = true
	var path = str("res://assets/ui/battle_action_icons/",associated_battle_action,".png")
	if FileAccess.file_exists(path):
		icon.texture = load(path)
		name_label.visible = false
	else:
		icon.texture = load("res://assets/ui/battle_action_icons/default.png")
		name_label.text = associated_battle_action
		icon.visible = true

func _on_pressed():
	animation_player.play("select")
var movement_tween:Tween = null
func swap(other,drop_pos=Vector2.ZERO):
	animation_player.play("focus")
	other.animation_player.play("focus")
	var pos = self.panel.global_position - other.global_position
	var parent_1 = self.get_parent()
	var index_1 = self.get_index()
	var parent_2 = other.get_parent()
	var index_2 = other.get_index()
	if parent_1 != parent_2:
		parent_1.remove_child(self)
		parent_2.remove_child(other)
		parent_1.add_child(other)
		parent_2.add_child(self)
	parent_1.move_child(other,index_1)
	parent_2.move_child(self,index_2)
	print("panel global positionn:",self.panel.global_position)
	self.panel.position = pos
	print("panel global positionnn:",self.panel.global_position)
	other.panel.position = drop_pos
	self.panel.z_index += 8
	other.panel.z_index += 8
	swaped.emit()
	const TWEEN_DURATION = 0.2
	if movement_tween:
		movement_tween.kill()
	movement_tween = create_tween()
	movement_tween.tween_property(self.panel,"position",Vector2(0,0),TWEEN_DURATION).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	if other.movement_tween:
		other.movement_tween.kill()
	other.movement_tween = create_tween()
	other.movement_tween.tween_property(other.panel,"position",Vector2(0,0),TWEEN_DURATION).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	movement_tween.finished.connect(func():self.panel.z_index -= 8)
	other.movement_tween.finished.connect(func():other.panel.z_index -= 8)
	
var is_being_dragged:bool = false
var drop_succesful:bool = false
var grab_delta:Vector2 = Vector2.ZERO
func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	if !data is Dictionary:
		return false
	if !data.has("other"):
		return false
	if !data["other"] is BattleActionTile:
		return false
	if data["other"].associated_battle_action == "":
		return false
	return true
func _drop_data(_at_position: Vector2, data: Variant) -> void:
	data["other"].drop_succesful = true
	data["other"].panel.visible = true
	swap(data["other"],data["grab_delta"]+_at_position)
func _get_drag_data(at_position: Vector2) -> Variant:
	is_being_dragged = true
	var preview = panel.duplicate()
	var preview_control = Control.new()
	preview_control.add_child(preview)
	preview_control.z_index = panel.z_index+3
	preview_control.scale = Vector2(1.1,1.1)
	preview.position = -at_position
	set_drag_preview(preview_control)
	panel.visible = false
	grab_delta = -at_position
	return {"other":self,"grab_delta":-at_position}
func _notification(what: int) -> void:
	if what == NOTIFICATION_DRAG_END && is_being_dragged:
		is_being_dragged = false
		panel.visible = associated_battle_action != ""
		if drop_succesful:
			drop_succesful = false
		else:
			panel.global_position = get_global_mouse_position()+grab_delta
			create_tween().tween_property(panel,"position",Vector2.ZERO,0.2).set_trans(Tween.TRANS_BOUNCE)
			panel.z_index += 3
			get_tree().create_timer(0.2).timeout.connect(func():panel.z_index-=3)
func _on_mouse_entered():
	grab_focus()
func _on_focus_entered():
	if !selected: animation_player.play("focus")
