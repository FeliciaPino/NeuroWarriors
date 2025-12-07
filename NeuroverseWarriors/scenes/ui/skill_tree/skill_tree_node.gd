@tool
extends Button
class_name SkillTreeNode
@export var prerequisites:Array[SkillTreeNode]:
	set(value):
		prerequisites = value
		if Engine.is_editor_hint():
			queue_redraw()
@export var associated_upgrade_name:String
var associated_upgrade:Upgrade

signal just_got_purchased
var purchased:bool = false
var available:bool = false
var active:bool = false
@onready var skill_tree:SkillTree = $".."
@onready var info_panel := %InfoPanel
@onready var level_req_label := %LevelReq
@onready var cost_label := %Cost
@onready var description_label := %Description
@onready var glow := $Glow
func _glow():
	create_tween().tween_property(glow,"scale",Vector2(1.3,1.3),0.5).set_ease(Tween.EASE_OUT)
func _unglow():
	create_tween().tween_property(glow,"scale",Vector2(0.5,0.5),0.5).set_ease(Tween.EASE_IN)
func _ready():
	if Engine.is_editor_hint():
		set_process(true)
		
	var path = str("res://assets/ui/upgrade_icons/",associated_upgrade_name,".png")
	if FileAccess.file_exists(path):
		icon = load(path)
	else:
		icon = load("res://assets/ui/battle_action_icons/default.png")
	associated_upgrade = CharacterDatabase.get_upgrade(associated_upgrade_name)
	if associated_upgrade == null:
		print_debug("ERRROR: could not load upgrade:",associated_upgrade_name)
	$InfoPanel/VBoxContainer/NameLabel.text = associated_upgrade.display_name
	description_label.text = associated_upgrade.description
	purchased = GameState.character_has_upgrade(skill_tree.associated_character,associated_upgrade.name_id)
	active = GameState.is_upgrade_active(skill_tree.associated_character,associated_upgrade.name_id)
	if active: _glow()
	level_req_label.text = str("LV: ",associated_upgrade.level_requirement)
	cost_label.text = str(tr("COST"),": ",associated_upgrade.tungesten_cost," ",tr("TUNGESTEN"))
	for prereq in prerequisites:
		prereq.just_got_purchased.connect(check_availability)
	CharacterDatabase.character_leveled_up.connect(func(character_name):if character_name==skill_tree.associated_character:check_availability())
	
	call_deferred("check_availability")
func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		queue_redraw()
func check_availability():
	print_debug(str(self,": checking availability for the amount of prereqs ",prerequisites.size()))
	available = true
	for prereq in prerequisites:
		print_debug(str(self,": checking prerequisite:",prereq))
		if not prereq.purchased:
			available = false
	if GameState.characters_save_info[skill_tree.associated_character]["level"] < associated_upgrade.level_requirement:
		available = false
	disabled = !available
	if available:
		description_label.text = str(associated_upgrade.description,"\npurchased:",purchased,"\n available:",available,"\nactive:",active)
	else:
		description_label.text = str("uug u cant, u need dis stuff:\n",)
		if GameState.characters_save_info[skill_tree.associated_character]["level"] < associated_upgrade.level_requirement:
			description_label.text += str("haz to b levl ",associated_upgrade.level_requirement,"\n")
		for prereq in prerequisites: if not prereq.purchased:
			description_label.text += prereq.associated_upgrade.display_name + "\n"
	if purchased: self_modulate = Color(0.9,0.9,0.9,1)
	else: self_modulate = Color(0.6,0.6,0.6,1)
	if active:
		self_modulate = Color.WHITE
func show_info():
	z_index = 10
	info_panel.visible = true
func hide_info():
	z_index = 10
	info_panel.visible = false
func throw_text(text_to_throw:String):
	var label = Label.new()
	label.text = text_to_throw
	self.add_child(label)
	label.position = Vector2(0,-20)
	print_debug(str(self,":throwing text, sizex:",label.size.x))
	label.position.x -= label.size.x/2
	label.position.x += size.x/2
	var tween = get_tree().create_tween().set_parallel()
	tween.tween_property(label,"position",Vector2(label.position.x,-60),1.2).set_ease(Tween.EASE_OUT)
	tween.tween_property(label,"modulate",Color(1,1,1,0),1.2).set_ease(Tween.EASE_OUT)
	tween.finished.connect(func():label.queue_free())
	
func _on_focus_entered():
	show_info()

func _on_focus_exited():
	hide_info()

func _on_mouse_entered():
	grab_focus()


func _on_pressed():
	show_info()
	if purchased:
		if associated_upgrade.type == Upgrade.UpgradeType.ABILITY_UNLOCK: return
		#toggle activation
		if active:
			GameState.deactivate_upgrade(skill_tree.associated_character,associated_upgrade.name_id)
			active = false
			_unglow()
			
		else:
			GameState.activate_upgrade(skill_tree.associated_character,associated_upgrade.name_id)
			active = true
			_glow()
		check_availability()#I just do this to update description, probably change it later
		return
	#enough tungesten?
	if GameState.get_tungesten_amount() < associated_upgrade.tungesten_cost:
		throw_text("Nut enouhasd tungestne, get more moola!")
		return
	purchased = true
	_glow()
	just_got_purchased.emit()
	GameState.set_tungesten_amount(GameState.get_tungesten_amount()-associated_upgrade.tungesten_cost)
	GameState.unlock_upgrade(skill_tree.associated_character,associated_upgrade.name_id)
	
	active = true
	GameState.activate_upgrade(skill_tree.associated_character,associated_upgrade.name_id)
	if associated_upgrade.type == Upgrade.UpgradeType.ABILITY_UNLOCK:
		GameState.unlock_ability(skill_tree.associated_character,associated_upgrade.associated_ability)
	check_availability()#I just do this to update description, probably change it later

#this is just so I can see the connections better in the editor
func _draw() -> void:
	if !Engine.is_editor_hint():
		return
	var center := size*0.5
	for p in prerequisites:
		if !p: continue
		
		draw_line(center, p.global_position-global_position+p.size*0.5, Color(0.9,0.9,0.9,0.5), 4)
		var dir := (p.global_position-global_position+p.size*0.5-center)
		dir = dir.normalized()
		draw_line(center+dir*40,center+dir.rotated(3.1416/4)*40+dir*40,Color(0.9,0.9,0.9,0.5), 4)
		draw_line(center+dir*40,center+dir.rotated(-3.1416/4)*40+dir*40,Color(0.9,0.9,0.9,0.5), 4)
