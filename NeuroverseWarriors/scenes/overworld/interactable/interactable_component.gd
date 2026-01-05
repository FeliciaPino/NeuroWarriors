extends Area2D
class_name InteractableComponent
signal interacted
var is_colliding:bool = false
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("accept") and is_colliding:
		print("AAAAAAAAA INTERACTED")
		interacted.emit()


func _on_area_entered(_area: Area2D) -> void:
	is_colliding = true

func _on_area_exited(_area: Area2D) -> void:
	is_colliding = false
