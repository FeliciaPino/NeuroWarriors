extends Node2D
@export var id:String
@export var level_path:String
@export var collider:Area2D
@export var interactable_component:InteractableComponent
func _ready() -> void:
	visible = false
	if GameState.is_level_completed(id):
		queue_free()
	else:
		visible = true
		if collider:
			collider.body_entered.connect(_on_body_entered)
		if interactable_component:
			interactable_component.interacted.connect(_go_to_encounter)
func _go_to_encounter():
	GameState.current_level = id
	BattleMaker.go_to_level(level_path)
func _on_body_entered(body: Node2D) -> void:
	print_debug(str(self,": somebody entered stgory trigger: ",body))
	if body.is_in_group("player"):
		print_debug("egads! it was the player, let's go to the level")
		call_deferred("_go_to_encounter")
