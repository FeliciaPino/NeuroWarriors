extends Control
var is_menu_open:bool = false
@onready var return_to_main_menu_button = %ReturnToMainMenuButton
func open_menu() -> void:
	if is_menu_open: return
	visible = true
	is_menu_open = true
func close_menu() -> void:
	if !is_menu_open: return
	visible = false
	is_menu_open = false
	
func toggle() -> void:
	if is_menu_open:
		close_menu()
	else:
		open_menu()
		
const main_menu_scene = preload("res://scenes/main_menu.tscn")

func leave_to_main_menu() -> void:
	get_tree().change_scene_to_packed(main_menu_scene)
	
	
func _on_return_to_main_menu_button_pressed() -> void:
	var dialog = ConfirmationDialog.new() 
	dialog.title = tr("BATTLE_MENU_LEAVE_TO_MENU_CONFIRMATION_DIALOGUE_TITLE")
	dialog.dialog_text = tr("BATTLE_MENU_LEAVE_TO_MENU_CONFIRMATION_DIALOGUE_TEXT")
	dialog.cancel_button_text = tr("UI_CANCEL")
	dialog.ok_button_text = tr("UI_CONFIRM")
	dialog.confirmed.connect(leave_to_main_menu)
	add_child(dialog)	
	dialog.popup_centered() # center on screen
	dialog.show()
	dialog.get_cancel_button().grab_focus()
	
	
func _on_close_menu_pressed() -> void:
	close_menu()
