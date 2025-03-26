extends MarginContainer
@onready var in_party_node := %InParty
@onready var not_in_party_node := %NotInParty

var currently_selected_character:CharacterPortrait = null

const character_portrait_scene = preload("res://scenes/ui/game_menu/character_portrait.tscn")
func _ready():
	var party = GameState.get_party()
	for character in party:
		var portrait:CharacterPortrait = character_portrait_scene.instantiate()
		_set_portrait_initial_values(portrait)
		in_party_node.add_child(portrait)
		portrait.set_associated_character(character)
	while in_party_node.get_child_count()<3:
		var portrait:CharacterPortrait = character_portrait_scene.instantiate()
		_set_portrait_initial_values(portrait)
		in_party_node.add_child(portrait)
		portrait.set_associated_character("")
	for character in CharacterDatabase.ALL_CHARACTERS:
		if not GameState.is_character_unlocked(character):
			continue
		var portrait:CharacterPortrait = character_portrait_scene.instantiate()
		_set_portrait_initial_values(portrait)
		not_in_party_node.add_child(portrait)
		if not GameState.is_character_in_party(character):
			portrait.set_associated_character(character)
		else:
			portrait.set_associated_character("")
	
func _set_portrait_initial_values(portrait:CharacterPortrait):
	portrait.in_party_node = in_party_node
	portrait.not_in_party_node = not_in_party_node
	portrait.party_menu_controller = self
func _process(_delta: float) -> void:
	var party:Array[String] = []
	for c:CharacterPortrait in in_party_node.get_children():
		if c.associated_character == "": continue
		party.append(c.associated_character)
	GameState.set_party(party)
	if currently_selected_character:
		var focus_owner = get_viewport().gui_get_focus_owner()
		if focus_owner is CharacterPortrait:
			pass
	
func character_portrait_pressed(pressed_character:CharacterPortrait):
	if currently_selected_character:
		pressed_character._close_buttons()
		currently_selected_character.swap(currently_selected_character,pressed_character)
		currently_selected_character = null
func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel") and currently_selected_character:
		currently_selected_character.animation_player.play("RESET")
		currently_selected_character.grab_focus()
		currently_selected_character = null
