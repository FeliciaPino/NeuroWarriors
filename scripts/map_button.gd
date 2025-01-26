extends TextureButton

@export var level_path:String
@export var level_name:String
@export var previous_level:String
@onready var label = $button_label 
@onready var level_select = $".."
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	label.text = level_name
	label.modulate.a = 0
	label.scale = Vector2()
	if not GameState.is_level_completed(previous_level):
		disabled = true
	if previous_level == "": disabled = false
	
func _on_mouse_entered() -> void:
	if disabled: return
	var tween = get_tree().create_tween().set_parallel()
	tween.tween_property(label, "modulate", Color(1,1,1,1) , 0.1)
	tween.tween_property(label, "scale", Vector2(1,1), 0.1)
	tween.tween_property(label, "position", Vector2(-70,-20), 0.1)


func _on_mouse_exited() -> void:
	var tween = get_tree().create_tween().set_parallel()
	tween.tween_property(label, "modulate", Color(1,1,1,0) , 0.1)
	tween.tween_property(label, "scale", Vector2(), 0.1)
	tween.tween_property(label, "position", Vector2(-70,10), 0.1)



func _on_pressed() -> void:
	#Change this later so it shows character select screen instead
	GameState.current_level = level_name
	level_select.load_level(level_path)
	
