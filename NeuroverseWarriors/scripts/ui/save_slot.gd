extends Control

@export var slot_index:int

@onready var load_button = %LoadButton
@onready var delete_button = %DeleteButton
# Called when the node enters the scene tree for the first time.
func _ready():
	update_text()
	load_button.pressed.connect(go_to_game)
	delete_button.pressed.connect(delete_save)
	
func update_text():
	load_button.text = tr("MAIN_MENU_SAVE_FILE").format({number = slot_index})
	var save_info = SaveManager.get_save_info(slot_index)
	if save_info == {}:
		load_button.text = load_button.text + " " + tr("MAIN_MENU_NEW_GAME")
	else:
		load_button.text = load_button.text + " " + tr("MAIN_MENU_CONTINUE")
func delete_save():
	SaveManager.delete_save(slot_index)
	update_text()
func go_to_game():
	SaveManager.load_game(slot_index)
	GameState.current_save_slot_index = slot_index
	GameState.start_game()
