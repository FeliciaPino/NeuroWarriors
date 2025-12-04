extends Node2D
class_name GameManager

@export var xp_reward = 0 #the amount of xp to be split among the party when winning

@onready var entity_manager:EntityManager = $Entity_manager
@onready var instruction_label = %InstructionLabel
@onready var end_turn_buttton:Button = %EndTurnButton
@onready var character_info_panel:BattleEntityInfoPanel = %CharacterInfoPanel
@onready var target_info_panel:BattleEntityInfoPanel = %TargetInfoPanel
@onready var animation_player = $AnimationPlayer
@onready var end_screen = %EndScreen
@onready var return_to_map_button:Button = %Return
@onready var background = $Background
@onready var tungesten_counter = %Tungesten_counter
var level_select_scene = preload("res://scenes/levels/level_select.tscn")


var party:Array[BattleEntity]
var foes:Array[BattleEntity]
var highlighted_character:BattleEntity = null
var selected_character:BattleEntity = null
signal selected_action_changed
var selected_action:BattleAction = null:
	set(new_value):
		selected_action = new_value
		selected_action_changed.emit()

signal pending_actions_updated
signal all_actions_finished
signal player_turn_ended
var pending_actions = 0: #How many actions are being currently done
	set(new_value):
		pending_actions = new_value
		pending_actions_updated.emit()
		if new_value == 0:
			all_actions_finished.emit()
var turn_count = 0
var is_player_turn:bool = true #is the player turn or the enemy turn.
var is_game_over:bool

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	MusicPlayer.play_music(load("res://addons/Pixel_boy/theme-7.ogg"))
	print_debug("current scene: "+str(get_tree().current_scene))
	add_to_group("GameManager")
	if background is AnimatedSprite2D:
		background.play("default")
		
	update_battle_entities()
	for party_member in entity_manager.get_party():
		party_member.is_player_controlled = true
	xp_reward = 0 #it increases for each enemy defeated
	for e:BattleEntity in entity_manager.entities:
		e.just_freaking_died_right_now.connect(_on_entity_defeated)
	
	end_turn_buttton.pressed.connect(end_turn)
	return_to_map_button.pressed.connect(return_to_menu)
		
	is_player_turn = true
	is_game_over = false
	turn_count = 0
	start_turn()
	#this should always be true
	if foes.size()>0:
		target_info_panel.set_entity_displayed(foes[0])
	#this should only happen on the test level, the starting character displayed will be set from battlemaker methinks
	if party.size()>0:
		character_info_panel.set_entity_displayed(party[0])

func return_to_menu():
	get_tree().change_scene_to_packed(load("res://scenes/main_menu.tscn"))

func update_battle_entities():
	entity_manager.update_focus_neighbours()
	party = entity_manager.get_party()
	foes = entity_manager.get_foes()
func end_turn():
	end_turn_buttton.disabled = true
	if is_game_over or not is_player_turn: return
	update_battle_entities()
	print_debug("turn ended")
	player_turn_ended.emit()
	is_player_turn = false
	for foe in foes: foe.set_up_at_start_of_turn()
	enemy_turn()
func start_turn():
	end_turn_buttton.disabled = false
	update_battle_entities()
	if turn_count != 0: if check_game_end(): return
	for character in party: character.set_up_at_start_of_turn()
	animation_player.play("start_player_turn")
	turn_count += 1
	print_debug("your turn")
func set_selected_character(character: BattleEntity):
	if character == selected_character: return
	print_debug("setting selected character to "+(character.entity_name if character else "null"))
	#close the menu if emptying selection
	if selected_character and not character: selected_character.close_menu()
	selected_character = character
	#When selecting a new character, clear previous displayed target
	if selected_character:
		character_info_panel.set_entity_displayed(selected_character)
		#target_info_panel.set_entity_displayed(null)
		pass
	
func set_selected_action(action: BattleAction):
	if is_game_over: return
	selected_action = action
	if selected_character != null: selected_character.close_menu()
	if not selected_action:
		instruction_label.visible = false
		return
	instruction_label.text = tr("BATTLE_TARGET_SELECT_HINT").format({verb=selected_action.verb})
	instruction_label.visible = true
	
	if action.isPositive:
		if selected_character:#this should always be true when selecting an action
			selected_character.button.grab_focus()
	else:
		foes[0].button.grab_focus()
#called by a battle entity when it is clicked
func battleEntityClicked(clicked_entity: BattleEntity):
	print_debug(clicked_entity.entity_name + " got clicked")
	#close the menu of all other entities
	for e in foes: if e != clicked_entity: e.close_menu()
	for e in party: if e != clicked_entity: e.close_menu()
	#if there's an action selected, then clicking on an entity executes it.
	if selected_action:
		#did an action!
		var act = selected_action
		set_selected_action(null)
		do_an_action(selected_character,act,clicked_entity)
		set_selected_character(null)
	else:
		if clicked_entity.is_player_controlled:
			set_selected_character(clicked_entity)
		else:
			set_selected_character(null)
		clicked_entity.open_menu()
#called by battle entity
func battle_entity_grabbed_focus(focused_entity:BattleEntity):
	#Update the the entity(ies) displayed in info panel(s)
	if not selected_action:
		#If there's already a character selected (with their menu up), show the info in the target panel (This should just happen with the mouse I reckon)
		if selected_character:
			target_info_panel.set_entity_displayed(focused_entity)
		else:
			#if there's no selected character already, display enemies on the right and teammates on the left
			if focused_entity.is_player_controlled:
				character_info_panel.set_entity_displayed(focused_entity)
			else:
				target_info_panel.set_entity_displayed(focused_entity)
	else:
		target_info_panel.set_entity_displayed(focused_entity)

func do_an_action(user:BattleEntity, action:BattleAction, target:BattleEntity):
	if not user or not target:
		return
	if not action.action_finished.is_connected(_on_action_finished):
		action.action_finished.connect(_on_action_finished.bind(action))
	print_debug("action started ", action.action_name)
	pending_actions += 1
	action.execute(user,target)
	
func _on_action_finished(action):
	print_debug("actions finished ", action.action_name)
	pending_actions -= 1
	if is_game_over: return
	update_battle_entities()
	if check_game_end(): return


func _on_pending_actions_updated() -> void:
	instruction_label.visible = true
	if pending_actions <0:
		instruction_label.text = "What the hell! There a negative amount of actions going on! That's not supposed to happen! Someone tell Copper there's a problem with her game"
		return
	if pending_actions == 0:
		instruction_label.text = " action finish"
		instruction_label.visible = false
	elif pending_actions == 1:
		instruction_label.text = "Waiting for action to finish"
	else:
		instruction_label.text = str("Waiting for ", pending_actions, " actions to finish")

func get_entity_by_name(entity_name:String)->BattleEntity:
	for entity in foes:
		if entity.entity_name == entity_name:
			return entity
	for entity in party:
		if entity.entity_name == entity_name:
			return entity
	return null

func _on_entity_defeated(entity:BattleEntity):
	if !entity.is_player_controlled:
		var tung_reward = _calc_tungesten_reward(entity)
		GameState.increase_tungesten_amount(tung_reward)
		
		xp_reward += _calc_xp_reward(entity)
		tungesten_counter.spawn_tungesten(entity.global_position,tung_reward)
func _calc_xp_reward(entity:BattleEntity):
	return entity.challenge_rating*60
func _calc_tungesten_reward(entity:BattleEntity):
	return entity.challenge_rating*4*randfn(1,0.30)
func check_game_end():
	if foes.size()<=0:
		finish(true)
		return true
	if party.size()<=0:
		finish(false)
		return true
	return false
	
func finish(win_status:bool):
	if is_game_over: return
	print_debug("finished "+str(win_status))
	is_game_over = true
	if win_status:
		GameState.mark_level_complete(GameState.current_level)
		GameState.mark_overworld_enemy_defeated(GameState.current_enemy_battle)
		if GameState.current_level == GameState.last_level:
			get_tree().change_scene_to_file("res://scenes/credits.tscn")
			return
	end_screen.set_win_status(win_status)
	animation_player.play("show_end_screen")

func enemy_turn():
	#Gotta wait for stuff to finish first, wouldn't want a player to kill an enemy on it's turn, that would just not be polite! and also crash the game
	while pending_actions > 0:
		await all_actions_finished
	
	print_debug("doing enemy turn")
	var foes_to_act = []
	for f in entity_manager.get_foes(): foes_to_act.append(f)
	while !foes_to_act.is_empty():
		var foe = foes_to_act.pick_random()
		while !is_instance_valid(foe):
			foes_to_act.erase(foe)
			if foes_to_act.is_empty(): break
			foe = foes_to_act.pick_random()
		if foes_to_act.is_empty(): break
		var decision = foe.figure_out_something_to_do()
		if decision["action"] == null:
			#this guy is done for this turn
			foes_to_act.erase(foe)
			continue
		do_an_action(foe, decision["action"], decision["target"])
		await decision["action"].action_finished
		
	is_player_turn = true
	start_turn()
	
func is_mouse_click_L(event: InputEvent):
	return event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed

func is_mouse_click_R(event: InputEvent):
	return event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed

func _unhandled_input(event: InputEvent) -> void:
	if is_mouse_click_L(event) and not selected_action:
		set_selected_character(null)
		for e in foes: e.close_menu()
	if event.is_action_pressed("ui_cancel"):
		print_debug(str(self,": ui cancel pressed"))
		#if theres an entity's menu opened, close it and make it grab focus
		var exited_a_menu = false
		for e in foes+party:
			if e.is_menu_opened:
				e.close_menu()
				e.button.grab_focus()
				exited_a_menu = true
		#if the ui_cancel wasn't used to leave a m
		if not exited_a_menu:
			pass
		
func _input(event: InputEvent) -> void:
	if is_mouse_click_R(event) || event.is_action_pressed("ui_cancel"):#clear selection
		for f in foes: f.close_menu()
		set_selected_action(null)
		if selected_character:
			selected_character.button.grab_focus()
		set_selected_character(null)
