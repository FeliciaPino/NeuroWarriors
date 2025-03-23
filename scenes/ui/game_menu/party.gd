extends MarginContainer
@onready var in_party_node := %InParty
@onready var not_in_party_node := %NotInParty

func _process(_delta: float) -> void:
	var party:Array[String] = []
	for c:CharacterPortrait in in_party_node.get_children():
		party.append(c.associated_character)
	GameState.set_party(party)
