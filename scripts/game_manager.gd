extends Node2D
class_name GameManager
@onready var entity_manager:EntityManager = $Entity_manager
@onready var selection_circle = $SelectionCircle #get rid of this
@onready var instruction_label = $InstructionLabel
@onready var end_turn_buttton:Button = $EndTurnButton
@onready var animation_player = $AnimationPlayer
@onready var end_screen = $EndScreen
@onready var return_to_map_button:Button = $Return
@onready var background = $Background
var level_select_scene = preload("res://scenes/levels/level_select.tscn")


var party:Array[BattleEntity]
var foes:Array[BattleEntity]
var highlighted_character:BattleEntity = null
var selected_character:BattleEntity = null
var selected_action:BattleAction = null

signal pending_actions_updated
signal all_actions_finished
var pending_actions = 0: #How many actions are being currently done
	set(new_value):
		pending_actions = new_value
		pending_actions_updated.emit()
		if new_value == 0:
			all_actions_finished.emit()
var turn_count = 0
var is_player_turn:bool = true #is the player turn or the enemy turn.
var is_game_over:bool

#neuro actions
const control_neuro_action := preload("res://scripts/neuro_actions/control_neuro_action.gd")
const control_vedal_action := preload("res://scripts/neuro_actions/control_vedal_action.gd")
const control_evil_action := preload("res://scripts/neuro_actions/control_evil_action.gd")
const end_turn_action := preload("res://scripts/neuro_actions/end_turn_action.gd")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("current scene: "+str(get_tree().current_scene))
	add_to_group("GameManager")
	if GameState.is_neuro_controlling:
		Context.send("Battle started. Neuro and her allies face off against a swarm of enemies. ", true)

	if background is AnimatedSprite2D:
		background.play("default")
		
	update_battle_entities()
	for party_member in party:
		party_member.is_player_controlled = true
	selection_circle.visible = false
	
	end_turn_buttton.pressed.connect(end_turn)
	
	return_to_map_button.pressed.connect(end_screen.leave)
		
	is_player_turn = true
	is_game_over = false
	print(str("neuro controlled: ",GameState.is_neuro_controlling))
	turn_count = 0
	start_turn()

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
	is_player_turn = false
	for foe in foes: foe.set_up_at_start_of_turn()
	enemy_turn()
func start_turn():
	end_turn_buttton.disabled = false
	if GameState.is_neuro_controlling:
		give_neuro_battle_context()
	update_battle_entities()
	if turn_count != 0: if check_game_end(): return
	for character in party: character.set_up_at_start_of_turn()
	animation_player.play("start_player_turn")
	turn_count += 1
	if GameState.is_neuro_controlling: make_neuro_play("your turn has started")
	print("your turn")
	
	
#This is for neuro integration, unused so far
func make_neuro_play(message:String):
	print("finna make neuro play")
	update_battle_entities()
	var actionWindow := ActionWindow.new(self)
	actionWindow.set_force(0, message, "", false)
	
	actionWindow.add_action(end_turn_action.new(actionWindow,self))
	var ved = get_entity_by_name("Vedal")
	if ved and ved.get_posible_actions().size() > 0: actionWindow.add_action(control_vedal_action.new(actionWindow,self))
	var neu = get_entity_by_name("Neuro Sama")
	if neu and neu.get_posible_actions().size() > 0: actionWindow.add_action(control_neuro_action.new(actionWindow, self))
	var evi = get_entity_by_name("Evil")
	if evi and evi.get_posible_actions().size() > 0: actionWindow.add_action(control_evil_action.new(actionWindow, self))
	actionWindow.register()

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
	Context.send(context,true)
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
	instruction_label.text = "select who to "+selected_action.verb
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
	if is_player_turn and  GameState.is_neuro_controlling:
		make_neuro_play("it is still your turn")


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
	end_screen.set_win_status(win_status)
	if win_status:
		GameState.mark_level_complete(GameState.current_level)
		if GameState.current_level == GameState.last_level:
			get_tree().change_scene_to_file("res://scenes/credits.tscn")
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
			
