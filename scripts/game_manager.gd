extends Node2D

@onready var entity_manager = $Entity_manager
@onready var selection_circle = $SelectionCircle
@onready var instruction_label = $InstructionLabel
@onready var end_turn_buttton = $EndTurnButton
@onready var animation_player = $AnimationPlayer
@onready var end_screen = $EndScreen
@onready var return_to_map_button = $Return
@onready var background = $Background
var level_select_scene = preload("res://scenes/levels/level_select.tscn")


var party:Array[BattleEntity]
var foes:Array[BattleEntity]
var highlighted_character:BattleEntity = null
var selected_character:BattleEntity = null
var selected_action:BattleAction = null

var stand_by:bool = false #it's in standby when waiting for the animations to finish
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
	start_turn()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	return
	if selected_character==null: # if there's no selected character we display the hovered one
		highlighted_character = null
		for character in party: if character.is_hovered_over_with_the_mouse:
			highlighted_character = character
func update_battle_entities():
	var previous_amounts = Vector2(party.size(),foes.size())
	party = entity_manager.get_party()
	foes = entity_manager.get_foes()
	if previous_amounts != Vector2(party.size(),foes.size()):
		entity_manager.update_entities_formations()
func end_turn():
	if is_game_over or not is_player_turn: return
	update_battle_entities()
	print("turn ended")
	is_player_turn = false
	for foe in foes: foe.set_up_at_start_of_turn()
	do_enemy_action()
func start_turn():
	give_neuro_battle_context()
	update_battle_entities()
	if check_game_end(): return
	for character in party: character.set_up_at_start_of_turn()
	animation_player.play("start_player_turn")
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
		selection_circle.visible = true
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
	action.action_finished.connect(func():on_action_finished(action))
	_set_stand_by(true)
	if not user or not target:
		return
	action.execute(user,target)
	
func on_action_finished(action):
	if is_game_over: return
	_set_stand_by(false)
	update_battle_entities()
	if check_game_end(): return
	if is_player_turn:
		if GameState.is_neuro_controlling: make_neuro_play("it is still your turn")
	else:
		do_enemy_action()

func _set_stand_by(value:bool):
	stand_by = value
	if stand_by:
		instruction_label.text = "waiting for action to finish"
		instruction_label.visible = true
	else:
		instruction_label.text = " action finish"
		instruction_label.visible = false

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
	print("finished "+str(win_status))
	is_game_over = true
	end_screen.set_win_status(win_status)
	if win_status:
		GameState.mark_level_complete(GameState.current_level)
		if GameState.current_level == GameState.last_level:
			get_tree().change_scene_to_file("res://scenes/credits.tscn")
	animation_player.play("show_end_screen")
#makes a movemente by the enmeies
func do_enemy_action():
		var thing_to_do = get_game_ai_action()
		if thing_to_do["ended_turn"]:
			is_player_turn = true
			print("enemy ended turn")
			start_turn()
		else:
			do_an_action(thing_to_do["user"],thing_to_do["action"],thing_to_do["target"])
	
func get_game_ai_action():
	#for now let's use a random algorithm, we can refine it later (by 'we' I of course mean 'I')
	var foes_that_can_still_do_stuff = []
	for foe in foes: if foe.are_there_posible_action(): foes_that_can_still_do_stuff.append(foe)
	var s = foes_that_can_still_do_stuff.size()
	if randf() < 0.2 or s==0:
		return{"ended_turn":true}
	var ai_selected_foe = foes_that_can_still_do_stuff.pick_random()
	var ai_selected_action = ai_selected_foe.get_strongest_posible_action()
	var ai_selected_target =  foes.pick_random() if ai_selected_action.isPositive else party.pick_random()
	return {"user":ai_selected_foe,"action":ai_selected_action,"target":ai_selected_target, "ended_turn":false}

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
			
