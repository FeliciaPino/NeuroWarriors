extends MarginContainer
@onready var in_party_node := %InParty
@onready var not_in_party_node := %NotInParty

var currently_selected_character:CharacterPortrait = null

func _process(_delta: float) -> void:
	var party:Array[String] = []
	for c:CharacterPortrait in in_party_node.get_children():
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
