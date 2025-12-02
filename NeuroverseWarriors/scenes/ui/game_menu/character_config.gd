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
signal selected_character_changed
var selected_character = ""
func set_selected_character(new_val):
	var prev = selected_character
	selected_character = new_val
	if prev != selected_character:
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
func load_character_info():
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
	ap_regen_label.text = str(tr("BATTLESTAT_AP_REGEN"),": ",character_battle_entity.speed)
	
func _on_selected_character_changed():
	load_character_info()
func _on_skill_tree_button_pressed():
	$"../..".close_menu()
	GameState.arrival_passage_name = ""
	get_tree().change_scene_to_packed(SKILL_TREE_SCENES[selected_character])

func _ready():
	selected_character_changed.connect(_on_selected_character_changed)
	carousel_left_button.pressed.connect(_on_swap_left_button_pressed)
	carousel_right_button.pressed.connect(_on_swap_right_button_pressed)
	update_characters_from_party()
	GameState.party_changed.connect(update_characters_from_party)
	$Label3.text = str("nwero quiped biliites: ",GameState.characters_save_info["Neuro-sama"]["equiped_abilities"])
	$Label4.text = str("newro not eqiped ablitis: ",GameState.characters_save_info["Neuro-sama"]["not_equiped_abilities"])
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
