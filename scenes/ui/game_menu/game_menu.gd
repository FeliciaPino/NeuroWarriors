extends Control

var menu_opened:bool = false

signal menu_has_just_opened
signal menu_has_just_closed
@onready var room:Room = $"../.."
# Called when the node enters the scene tree for the first time.
func _ready():
	visible = false
	get_tree().paused
func toggle():
	if menu_opened:
		close_menu()
	else:
		open_menu()
func open_menu():
	print_debug(str(self,": opening menu"))
	room.current_mode = Room.Mode.MENU
	if not menu_opened:
		MusicPlayer.muffle()
		menu_has_just_opened.emit()
	get_tree().paused = true
	visible = true
	menu_opened = true
	$TabContainer.get_tab_bar().grab_focus()
	get_viewport().set_input_as_handled()
func close_menu():
	print_debug(str(self,": closing menu"))
	room.current_mode = Room.Mode.GAMEPLAY
	if menu_opened:
		MusicPlayer.un_muffle()
		menu_has_just_closed.emit()
	
	#keep processing for a little while, to finish animations and whatnot
	process_mode = PROCESS_MODE_ALWAYS
	get_tree().create_timer(0.25).timeout.connect(func():process_mode = PROCESS_MODE_WHEN_PAUSED)
	get_tree().paused = false
	visible = false
	menu_opened = false
	get_viewport().set_input_as_handled()
func make_tab_grab_focus():
	$TabContainer.grab_focus()

func _input(event):
	if not room.current_mode == Room.Mode.MENU: return
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_E :
			print_debug(str(self,"toggling"))
			toggle()
		if event.is_action_pressed("ui_cancel"):
			close_menu()
