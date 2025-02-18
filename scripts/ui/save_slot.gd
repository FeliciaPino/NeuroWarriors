extends Control

@export var slot_index:int

@onready var load_button = %LoadButton
@onready var delete_button = %DeleteButton
# Called when the node enters the scene tree for the first time.
func _ready():
	update_text()
	#Load more infor about the save file in  the future, time played and stuff
	load_button.pressed.connect(go_to_game)
	delete_button.pressed.connect(SaveManager.delete_save.bind(slot_index))
	
func update_text():
	load_button.text = tr("MAIN_MENU_SAVE_FILE").format({number = slot_index})
func go_to_game():
	SaveManager.load_game(slot_index)
	GameState.current_save_slot_index = slot_index
	GameState.start_game()
