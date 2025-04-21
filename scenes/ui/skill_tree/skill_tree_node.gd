extends Button
class_name SkillTreeNode
@export var prerequisites:Array[SkillTreeNode]
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

func _ready():
	associated_upgrade = CharacterDatabase.get_upgrade(associated_upgrade_name)
	text = associated_upgrade.display_name
	description_label.text = associated_upgrade.description
	purchased = GameState.character_has_upgrade(skill_tree.associated_character,associated_upgrade.name_id)
	active = GameState.is_upgrade_active(skill_tree.associated_character,associated_upgrade.name_id)
	level_req_label.text = str("LV: ",associated_upgrade.level_requirement)
	cost_label.text = str(tr("COST"),": ",associated_upgrade.tungesten_cost," ",tr("TUNGESTEN"))
	for prereq in prerequisites:
		prereq.just_got_purchased.connect(check_availability)
	CharacterDatabase.character_leveled_up.connect(func(character_name):if character_name==skill_tree.associated_character:check_availability())
	CharacterDatabase.character_leveled_up.connect(func(character_name):print_debug(str("I heard someone leveled up")))
	call_deferred("check_availability")
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
	if purchased:
		if associated_upgrade.type == Upgrade.UpgradeType.ABILITY_UNLOCK: return
		#toggle activation
		if active:
			GameState.deactivate_upgrade(skill_tree.associated_character,associated_upgrade.name_id)
			active = false
		else:
			GameState.activate_upgrade(skill_tree.associated_character,associated_upgrade.name_id)
			active = true
		check_availability()#I just do this to update description, probably change it later
		return
	#enough tungesten?
	if GameState.get_tungesten_amount() < associated_upgrade.tungesten_cost:
		throw_text("Nut enouhasd tungestne, get more moola!")
		return
	purchased = true
	just_got_purchased.emit()
	GameState.set_tungesten_amount(GameState.get_tungesten_amount()-associated_upgrade.tungesten_cost)
	GameState.unlock_upgrade(skill_tree.associated_character,associated_upgrade.name_id)
	if not associated_upgrade.type == Upgrade.UpgradeType.ABILITY_UNLOCK:
		active = true
		GameState.activate_upgrade(skill_tree.associated_character,associated_upgrade.name_id)
	else:
		GameState.unlock_ability(skill_tree.associated_character,associated_upgrade.associated_ability)
	check_availability()#I just do this to update description, probably change it later
