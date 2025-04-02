extends Node2D
class_name GameManager

@export var xp_reward:int = 0 #the amount of xp to be split among the party when winning

@onready var entity_manager:EntityManager = $Entity_manager
@onready var selection_circle = $SelectionCircle #get rid of this
@onready var instruction_label = %InstructionLabel
@onready var end_turn_buttton:Button = %EndTurnButton
@onready var animation_player = $AnimationPlayer
@onready var end_screen = $EndScreen
@onready var return_to_map_button:Button = %Return
@onready var background = $Background
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
	print("current scene: "+str(get_tree().current_scene))
	add_to_group("GameManager")
	if background is AnimatedSprite2D:
		background.play("default")
		
	update_battle_entities()
	for party_member in party:
		party_member.is_player_controlled = true
	selection_circle.visible = false
	
	end_turn_buttton.pressed.connect(end_turn)
	
	return_to_map_button.pressed.connect(return_to_menu)
		
	is_player_turn = true
	is_game_over = false
	turn_count = 0
	start_turn()
func return_to_menu():
	get_tree().change_scene_to_packed(load("res://scenes/main_menu.tscn"))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	return
	if selected_character==null: # if there's no selected character we display the hovered one
		highlighted_character = null
		for character in party: if character.is_hovered_over_with_the_mouse:
			highlighted_character = character
func update_battle_entities():
	party = entity_manager.get_party()
	foes = entity_manager.get_foes()
func end_turn():
	end_turn_buttton.disabled = true
	if is_game_over or not is_player_turn: return
	update_battle_entities()
	print("turn ended")
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
	print("your turn")
	
#This is for neuro integration, unused so far
func give_neuro_battle_context():
	var context = "Battlefield status:\n"
	for character in party:
		context += str("-",character.entity_name," AP:",character.ap,", HP:",character.health,", Actions:")
		for action in character.actions:
			context += str(action.action_name,":",action.price," ")
		context += " "
		for sta_eff in character.effects_container.get_children():
			context += sta_eff.effect_name+","
		context+="\n"
	context += "foes:\n"
	for character in foes:
		context += str("-",character.entity_name," AP:",character.ap,", HP:",character.health,", Actions:")
		for action in character.actions:
			context += str(action.action_name,":",action.price)
		context += " "
		for sta_eff in character.effects_container.get_children():
			context += sta_eff.effect_name+","
		context+="\n"
func set_selected_character(character: BattleEntity):
	if selected_character != null: selected_character.close_menu()
	selected_character = character
	if selected_character == null:
		selection_circle.visible = false
	else:
		selected_character.open_menu()
		#selection_circle.visible = true
		selection_circle.position = selected_character.position

	
func set_selected_action(action: BattleAction):
	selected_action = action
	if selected_character != null: selected_character.close_menu()
	if selected_action == null:
		instruction_label.visible = false
		return
	instruction_label.text = tr("BATTLE_TARGET_SELECT_HINT").format({verb=selected_action.verb})
	instruction_label.visible = true
#called by a battle entity when it is clicked
func battleEntityClicked(clicked_entity: BattleEntity):
	if selected_action != null:
		#did an action!
		var act = selected_action
		set_selected_action(null)
		do_an_action(selected_character,act,clicked_entity)
		set_selected_character(null)
	elif selected_character == null and clicked_entity.is_player_controlled:
		set_selected_character(clicked_entity)
	elif not clicked_entity.is_player_controlled:
		clicked_entity.toggle_menu()
	

func do_an_action(user:BattleEntity, action:BattleAction, target:BattleEntity):
	if not user or not target:
		return
	if not action.action_finished.is_connected(_on_action_finished):
		action.action_finished.connect(_on_action_finished.bind(action))
	print("action started ", action.action_name)
	pending_actions += 1
	action.execute(user,target)
	
func _on_action_finished(action):
	print("actions finished ", action.action_name)
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
	print("finished "+str(win_status))
	is_game_over = true
	if win_status:
		for p in party:
			CharacterDatabase.gain_xp(p.entity_name,xp_reward/party.size())
		GameState.mark_level_complete(GameState.current_level)
		GameState.mark_overworld_enemy_defeated(GameState.current_enemy_battle)
		if GameState.current_level == GameState.last_level:
			get_tree().change_scene_to_file("res://scenes/credits.tscn")
			return
	end_screen.set_win_status(win_status)
	animation_player.play("show_end_screen")

func enemy_turn():
	print("doing enemy turn")
	#Gotta wait for stuff to finish first, wouldn't want a player to kill an enemy on it's turn, that would just not be polite! and also crash the game
	while pending_actions > 0:
		await all_actions_finished
	var foes_to_act = []
	for f in foes: foes_to_act.append(f)
	while not foes_to_act.is_empty():
		var foe:BattleEntity = foes_to_act.pick_random()
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
	if is_mouse_click_L(event):
		if selected_action == null:
			for foe in foes:
				if not foe.is_hovered_over_with_the_mouse: foe.close_menu()
		
		if selected_character != null:
			if not selected_character.is_hovered_over_with_the_mouse and selected_action == null:
				set_selected_character(null)
func _input(event: InputEvent) -> void:
	if is_mouse_click_R(event):
		for f in foes: f.close_menu()
		set_selected_action(null)
		set_selected_character(null)
			
