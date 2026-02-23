extends Area2D
class_name InteractableComponent
##Animation player that plays when interacted
@export var animation_player:AnimationPlayer
##Name of the animation that plays when interacted, the animation player must have an animation with this name
@export var animation_name:String
signal interacted
var is_colliding:bool = false
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("accept") and is_colliding:
		interacted.emit()
		if animation_player:
			animation_player.play(animation_name)


func _on_area_entered(_area: Area2D) -> void:
	is_colliding = true

func _on_area_exited(_area: Area2D) -> void:
	is_colliding = false
