extends Control
class_name BattleEntityInfoPanel
@export var battle_entity:BattleEntity
var battle_entity_preview:BattleEntity#Ususally null, when set shows the differences from battle_entity, (used to display the predicted effects of actions)
@onready var name_label := %Name_Label
@onready var description_label := %Description_Label
@onready var entity_viewport := %Entity_Viewport
@onready var entity_viewport_camera := %Entity_Viewport_Camera
@onready var stats_container := %Stats_Container
@onready var health_label := %Health_Label
@onready var attack_label := %Attack_Label
@onready var defense_label := %Defense_Label
@onready var ap_regen_label := %AP_Regen_Label
func _ready() -> void:
	entity_viewport.world_2d = get_viewport().world_2d
	if not battle_entity:
		_remove_info()
func set_entity_displayed(new_entity:BattleEntity):
	battle_entity = new_entity
	entity_viewport.get_parent().visible = true
	if not new_entity:
		_remove_info()
func _remove_info():
	name_label.text = ""
	description_label.text = ""
	entity_viewport.get_parent().visible = false
	for c in stats_container.get_children():
		if not c is Label:
			continue
		c.text = ""
		if not(c==health_label or c==attack_label or c==defense_label or c==ap_regen_label):
			c.queue_free()
func _process(delta):
	if not battle_entity:
		return
	name_label.text = battle_entity.entity_name
	description_label.text =  battle_entity.entity_description
	health_label.text = str(tr("BATTLESTAT_HEALTH"),":",battle_entity.health,"/",battle_entity.maxHealth)
	attack_label.text = str(tr("BATTLESTAT_ATTACK"),":",battle_entity.attack)
	defense_label.text = str(tr("BATTLESTAT_DEFENSE"),":",battle_entity.defense)
	ap_regen_label.text = str(tr("BATTLESTAT_AP_REGEN"),":",battle_entity.speed)
	
	entity_viewport_camera.global_position = battle_entity.global_position
