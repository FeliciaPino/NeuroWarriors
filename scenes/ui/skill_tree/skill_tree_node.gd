extends Control
class_name SkillTreeNode
@export var prerequisites:Array[SkillTreeNode]
var associated_upgrade_name:String
var associated_upgrade:Upgrade

@onready var info_panel := %InfoPanel
@onready var level_req_label := %LevelReq
@onready var cost_label := %Cost
@onready var description_label := %Description

func _ready():
	associated_upgrade = CharacterDatabase.get_upgrade(associated_upgrade_name)


func show_info():
	info_panel.scale.y = 0
	info_panel.position.y = 0
	var tween = get_tree().create_tween().set_parallel()
	tween.tween_property(info_panel,"scale",Vector2(1,1),0.05)
	tween.tween_property(info_panel,"position",Vector2(info_panel.position.x,75),0.05)
	info_panel.visible = true
func hide_info():
	var tween = get_tree().create_tween().set_parallel()
	tween.tween_property(info_panel,"scale",Vector2(1,0),0.05)
	tween.tween_property(info_panel,"position",Vector2(info_panel.position.x,0),0.05)
	await tween.finished
	info_panel.visible = false

func _on_focus_entered():
	show_info()

func _on_focus_exited():
	hide_info()
