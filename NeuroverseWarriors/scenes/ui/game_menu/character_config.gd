extends Control


const SKILL_TREE_SCENES = {
	CharacterDatabase.NEURO_SAMA : preload("res://scenes/ui/skill_tree/neuro_sama_skill_tree.tscn"),
	CharacterDatabase.VEDAL : preload("res://scenes/ui/skill_tree/vedal_skill_tree.tscn"),
	CharacterDatabase.EVIL : preload("res://scenes/ui/skill_tree/evil_skill_tree.tscn"),
	CharacterDatabase.ANNY : preload("res://scenes/ui/skill_tree/anny_skill_tree.tscn")
}
const CAROUSEL_ROTATION_DURATION = 0.15

@onready var character_portrait_left := %CharacterPortraitLeft
@onready var character_portrait_front := %CharacterPortraitFront
@onready var character_portrait_right := %CharacterPortraitRight
@onready var carousel_right_button = %CarouselRight
@onready var carousel_left_button = %CarouselLeft
@onready var skill_tree_button = %SkillTreeButton
@onready var level_label = %LevelLabel
@onready var health_label = %HealthLabel
@onready var attack_label = %AttackLabel
@onready var defense_label = %DefenseLabel
@onready var ap_regen_label = %ApRegenLabel
@onready var description_label = %DescriptionLabel

@onready var equiped_abilites_container = %EquipedAbilities
@onready var not_equiped_abilites_container = %NotEquipedAbilities
@onready var scroll_container := $MarginContainer/HBoxContainer/VBoxContainer2/MarginContainer/VBoxContainer/ScrollContainer
signal selected_character_changed
var selected_character = ""
var selected_battle_action_tile = null
func update_battle_action_info(battle_action_name:String):
	if battle_action_name == "":
		return
	var battle_action:BattleAction = CharacterDatabase.get_battle_action_scene(battle_action_name).instantiate()
	self.add_child(battle_action)
	$MarginContainer/HBoxContainer/VBoxContainer2/MarginContainer2/VBoxContainer/Label.text = battle_action.action_name
	$MarginContainer/HBoxContainer/VBoxContainer2/MarginContainer2/VBoxContainer/Label2.text = battle_action.description
func _on_focus_changed(node):
	if !node: return
	if node is BattleActionTile:
		update_battle_action_info(node.associated_battle_action)
		if scroll_container.is_ancestor_of(node) and !GameState.controlling_with_the_mouse:
			var tween = create_tween()
			if node.get_index()*62>scroll_container.scroll_horizontal+62*2:
				tween.tween_property(scroll_container,"scroll_horizontal",node.get_index()*62-62*2,0.3)
			elif node.get_index()*62<scroll_container.scroll_horizontal+62*2:
				tween.tween_property(scroll_container,"scroll_horizontal",node.get_index()*62-62*2,0.3)
			else:
				tween.kill()
func quick_swap(mt:BattleActionTile,bat:BattleActionTile):
	#bat will now have a battle action and mt will be empty. (because this is supposed to be called only to automatically swap with an empty tile)
	bat.swap(mt)
	var par = mt.get_parent()
	par.get_child(min(mt.get_index()+1,par.get_child_count()-1)).grab_focus()
	for i in range(mt.get_index()+1,par.get_child_count()):
		var a:BattleActionTile = par.get_child(i-1)
		var b:BattleActionTile = par.get_child(i)
		await get_tree().process_frame
		a.swap(b,b.panel.global_position-a.global_position)
func _on_battle_action_tile_pressed(bat:BattleActionTile):
	if selected_battle_action_tile:
		selected_battle_action_tile.selected = false
		bat.swap(selected_battle_action_tile,selected_battle_action_tile.global_position-bat.global_position)
		selected_battle_action_tile.grab_focus()
		selected_battle_action_tile = null
	elif bat.associated_battle_action != "":
		if bat.get_parent() == equiped_abilites_container:
			for c:BattleActionTile in not_equiped_abilites_container.get_children():
				if c.associated_battle_action == "":
					quick_swap(c,bat)
					return
		else:
			for c:BattleActionTile in equiped_abilites_container.get_children():
				if c.associated_battle_action == "":
					quick_swap(c,bat)
					return
		if bat.get_parent() == equiped_abilites_container:
			if not_equiped_abilites_container.get_child_count()>0:
				not_equiped_abilites_container.get_child(min(not_equiped_abilites_container.get_child_count()-1,bat.get_index())).grab_focus()
		else:
			if equiped_abilites_container.get_child_count()>0:
				equiped_abilites_container.get_child(min(equiped_abilites_container.get_child_count()-1,bat.get_index())).grab_focus()
		bat.selected = true
		selected_battle_action_tile = bat
func set_selected_character(new_val):
	selected_character = new_val
	selected_character_changed.emit()
func update_characters_from_party():
	var party = GameState.get_party()
	if party.size() == 3:
		carousel_left_button.visible = true
		carousel_right_button.visible = true
		set_selected_character(party[0])
		character_portrait_front.set_associated_character(party[0])
		character_portrait_right.set_associated_character(party[1])
		character_portrait_right.visible = true
		character_portrait_left.set_associated_character(party[2])
		character_portrait_left.visible = true
	if party.size() == 2:
		carousel_left_button.visible = false
		carousel_right_button.visible = true
		set_selected_character(party[0])
		character_portrait_front.set_associated_character(party[0])
		character_portrait_right.set_associated_character(party[1])
		character_portrait_right.visible = true
		character_portrait_left.visible = false
		
	if party.size() == 1:
		carousel_left_button.visible = false
		carousel_right_button.visible = false
		set_selected_character(party[0])
		character_portrait_front.set_associated_character(party[0])
		character_portrait_right.visible = false
		character_portrait_left.visible = false
const battle_action_tile_scene = preload("res://scenes/ui/game_menu/battle_action_tile.tscn")
#ya got a better function name? It's descriptive!
func update_gamestate_battle_actions_of_the_selected_character():
	var equiped_actions:Array[String] = []
	for c:BattleActionTile in equiped_abilites_container.get_children():
		if c.associated_battle_action != "":
			equiped_actions.append(c.associated_battle_action)
	GameState.set_character_equiped_battle_actions(selected_character,equiped_actions)
	var unequiped_actions:Array[String] = []
	for c:BattleActionTile in not_equiped_abilites_container.get_children():
		if c.associated_battle_action != "":
			unequiped_actions.append(c.associated_battle_action)
	GameState.set_character_not_equiped_battle_actions(selected_character,unequiped_actions)
func update_action_tiles_focus_neighbors():
	for c:BattleActionTile in equiped_abilites_container.get_children():
		if c.get_index() == 0:
			if GameState.get_party().size()<=1:
				c.focus_neighbor_left = skill_tree_button.get_path()
			else:
				c.focus_neighbor_left = carousel_right_button.get_path()
			carousel_right_button.focus_neighbor_right = c.get_path()
		else:
			c.focus_neighbor_left = equiped_abilites_container.get_child(c.get_index()-1).get_path()
		if c.get_index() < equiped_abilites_container.get_child_count()-1:
			c.focus_neighbor_right = equiped_abilites_container.get_child(c.get_index()+1).get_path()
	for c:BattleActionTile in not_equiped_abilites_container.get_children():
		if c.get_index()==0:
			c.focus_neighbor_left = skill_tree_button.get_path()
		else:
			c.focus_neighbor_left = not_equiped_abilites_container.get_child(c.get_index()-1).get_path()
		if c.get_index() < not_equiped_abilites_container.get_child_count()-1:
			c.focus_neighbor_right = not_equiped_abilites_container.get_child(c.get_index()+1).get_path()
		
#updates the action tiles so they represetn the ones of the selected character
func update_action_tiles():
	for c in equiped_abilites_container.get_children(): c.queue_free()
	for c in not_equiped_abilites_container.get_children(): c.queue_free()
	await get_tree().process_frame
	var equiped_BA = GameState.get_character_equiped_battle_actions(selected_character)
	for ba in equiped_BA:
		var new_tile:BattleActionTile = battle_action_tile_scene.instantiate()
		new_tile.associated_battle_action=ba
		equiped_abilites_container.add_child(new_tile)
	for x in range(GameState.get_character_max_equiped_actions(selected_character) - equiped_BA.size()):
		equiped_abilites_container.add_child(battle_action_tile_scene.instantiate())
	for c:BattleActionTile in equiped_abilites_container.get_children():
		c.pressed.connect(_on_battle_action_tile_pressed.bind(c))
		c.swaped.connect(update_gamestate_battle_actions_of_the_selected_character)
		c.swaped.connect(update_action_tiles_focus_neighbors)
	var n_equiped_BA = GameState.get_character_not_equiped_battle_actions(selected_character)
	for ba in n_equiped_BA:
		var new_tile:BattleActionTile = battle_action_tile_scene.instantiate()
		not_equiped_abilites_container.add_child(new_tile)
		new_tile.set_associated_battle_action(ba)
	for x in range(equiped_BA.size()): #add empty slot on the unequiped list for everyone you do have equiped, so in total the slots for unequiped actions is the same as the total amount of battle actions this character has
		not_equiped_abilites_container.add_child(battle_action_tile_scene.instantiate())
	for c:BattleActionTile in not_equiped_abilites_container.get_children():
		c.pressed.connect(_on_battle_action_tile_pressed.bind(c))
		c.swaped.connect(update_gamestate_battle_actions_of_the_selected_character)
		c.swaped.connect(update_action_tiles_focus_neighbors)
	
	update_action_tiles_focus_neighbors()
func load_character_info():
	update_action_tiles()
	skill_tree_button.text = tr("GAME_MENU_CHARACTER_SKILL_TREE").format({character=selected_character})
	var char_level := GameState.get_character_level(selected_character)
	var char_remainging_xp := int(CharacterDatabase.xp_needed_to_level_up(char_level) - GameState.get_character_xp(selected_character))
	level_label.text = tr("GAME_MENU_CHARACTER_XP").format({level=char_level,remaining=char_remainging_xp})
	var character_battle_entity:BattleEntity = CharacterDatabase.get_entity_scene(selected_character).instantiate()
	CharacterDatabase.apply_level(character_battle_entity,char_level)
	for u:Upgrade in GameState.get_character_active_upgrades(selected_character):
		if u.type == Upgrade.UpgradeType.ENTITY_MOD:
			u.apply_to_entity(character_battle_entity)
	health_label.text = str(tr("BATTLESTAT_HEALTH"),": ",character_battle_entity.maxHealth)
	attack_label.text = str(tr("BATTLESTAT_ATTACK"),": ",character_battle_entity.attack)
	defense_label.text = str(tr("BATTLESTAT_DEFENSE"),": ",character_battle_entity.defense)
	ap_regen_label.text = str(tr("BATTLESTAT_AP_REGEN"),": ",character_battle_entity.ap_regen)
	
func _on_selected_character_changed():
	load_character_info()
func _on_skill_tree_button_pressed():
	$"../..".close_menu()
	GameState.arrival_passage_name = ""
	get_tree().change_scene_to_packed(SKILL_TREE_SCENES[selected_character])

func _ready():
	get_viewport().gui_focus_changed.connect(_on_focus_changed)
	selected_character_changed.connect(_on_selected_character_changed)
	carousel_left_button.pressed.connect(_on_swap_left_button_pressed)
	$MarginContainer/HBoxContainer/VBoxContainer/PartyCarousel/Button.pressed.connect(_on_swap_left_button_pressed)
	carousel_right_button.pressed.connect(_on_swap_right_button_pressed)
	$MarginContainer/HBoxContainer/VBoxContainer/PartyCarousel/Button2.pressed.connect(_on_swap_right_button_pressed)
	update_characters_from_party()
	GameState.party_changed.connect(update_characters_from_party)
func swap_3(a:CharacterPortrait, b:CharacterPortrait, c:CharacterPortrait):
	var tween = create_tween()
	tween.set_parallel()
	tween.tween_property(a,"position",b.position,CAROUSEL_ROTATION_DURATION)
	tween.tween_property(a,"modulate",b.modulate,CAROUSEL_ROTATION_DURATION)
	tween.tween_property(a,"scale",b.scale,CAROUSEL_ROTATION_DURATION)
	tween.tween_property(a,"z_index",b.z_index,CAROUSEL_ROTATION_DURATION/2)
	tween.tween_property(b,"position",c.position,CAROUSEL_ROTATION_DURATION)
	tween.tween_property(b,"modulate",c.modulate,CAROUSEL_ROTATION_DURATION)
	tween.tween_property(b,"scale",c.scale,CAROUSEL_ROTATION_DURATION)
	tween.tween_property(b,"z_index",c.z_index,CAROUSEL_ROTATION_DURATION/2)
	tween.tween_property(c,"position",a.position,CAROUSEL_ROTATION_DURATION)
	tween.tween_property(c,"modulate",a.modulate,CAROUSEL_ROTATION_DURATION)
	tween.tween_property(c,"scale",a.scale,CAROUSEL_ROTATION_DURATION)
	c.z_index = 0 #c is the one on the right, and it's gotta be behind all the rotation, so this'll help that I think
	tween.tween_property(c,"z_index",a.z_index,CAROUSEL_ROTATION_DURATION)
func swap_2(a:CharacterPortrait, b:CharacterPortrait):
	var tween = create_tween()
	tween.set_parallel()
	tween.tween_property(a,"position",b.position,CAROUSEL_ROTATION_DURATION)
	tween.tween_property(b,"position",a.position,CAROUSEL_ROTATION_DURATION)
	tween.tween_property(a,"modulate",b.modulate,CAROUSEL_ROTATION_DURATION)
	tween.tween_property(b,"modulate",a.modulate,CAROUSEL_ROTATION_DURATION)
	tween.tween_property(a,"scale",b.scale,CAROUSEL_ROTATION_DURATION)
	tween.tween_property(b,"scale",a.scale,CAROUSEL_ROTATION_DURATION)
	tween.tween_property(a,"z_index",b.z_index,CAROUSEL_ROTATION_DURATION)
	tween.tween_property(b,"z_index",a.z_index,CAROUSEL_ROTATION_DURATION)
func _on_swap_left_button_pressed():
	carousel_left_button.disabled = true
	set_selected_character(character_portrait_left.associated_character)
	
	swap_3(character_portrait_left,character_portrait_front,character_portrait_right)
	await get_tree().create_timer(CAROUSEL_ROTATION_DURATION).timeout
	carousel_left_button.disabled=false
	var tmp = character_portrait_left
	character_portrait_left = character_portrait_right
	character_portrait_right = character_portrait_front
	character_portrait_front = tmp
	
func _on_swap_right_button_pressed():
	carousel_right_button.disabled = true
	if character_portrait_left.visible:
		swap_3(character_portrait_right, character_portrait_front, character_portrait_left)
	else:
		swap_2(character_portrait_front,character_portrait_right)
	set_selected_character(character_portrait_right.associated_character)
	await  get_tree().create_timer(CAROUSEL_ROTATION_DURATION).timeout
	carousel_right_button.disabled = false
	var tmp = character_portrait_right
	if character_portrait_left.visible:
		character_portrait_right = character_portrait_left
		character_portrait_left = character_portrait_front
	else:
		character_portrait_right = character_portrait_front
	character_portrait_front = tmp
	
func _on_debugton_pressed():
	$"../..".close_menu()
	GameState.arrival_passage_name = ""
	get_tree().change_scene_to_packed(SKILL_TREE_SCENES["Neuro-sama"])
