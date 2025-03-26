extends Control

var menu_opened:bool = false

signal menu_has_just_opened
signal menu_has_just_closed
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
	print(str(self,": opening menu"))
	if not menu_opened:
		MusicPlayer.muffle()
		menu_has_just_opened.emit()
	get_tree().paused = true
	visible = true
	menu_opened = true
	get_viewport().set_input_as_handled()
func close_menu():
	print(str(self,": closing menu"))
	if menu_opened:
		MusicPlayer.un_muffle()
		menu_has_just_closed.emit()
	get_tree().paused = false
	visible = false
	menu_opened = false
	get_viewport().set_input_as_handled()
func make_tab_grab_focus():
	$TabContainer.grab_focus()

func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_E:
			print(str(self,"toggling"))
			toggle()
