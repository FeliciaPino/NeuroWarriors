extends Node2D
class_name DialogueTrigger
signal dialogue_triggered

@onready var dialogue_manager:DialogueManager = %DialogueManager

@export var interactable_component:InteractableComponent
@export var area_trigger:Area2D

@export var path_to_dialogue_sequence:String

@export var animation_before:AnimationPlayer
@export var animation_after:AnimationPlayer
func _ready() -> void:
	for c in get_children():
		if c is InteractableComponent:
			interactable_component = c
		elif c is Area2D:
			area_trigger = c
	if interactable_component:
		interactable_component.interacted.connect(dialogue_triggered.emit)
	if area_trigger:
		area_trigger.body_entered.connect(_on_area_entered)
	dialogue_triggered.connect(_on_dialogue_triggered)
func _on_dialogue_triggered():
	if animation_before:
		if animation_before.has_animation("new_animation"):
			get_tree().paused = true
			var tmp1 = animation_before.process_mode
			var tmp2 = dialogue_manager.room.party_node.process_mode
			animation_before.process_mode = Node.PROCESS_MODE_ALWAYS
			dialogue_manager.room.party_node.process_mode = Node.PROCESS_MODE_ALWAYS
			animation_before.play("new_animation")
			await animation_before.animation_finished
			animation_before.process_mode = tmp1
			dialogue_manager.room.party_node.process_mode = tmp2
			dialogue_manager.room.party_node.end_being_controlled_by_animation()
	
	if path_to_dialogue_sequence: dialogue_manager.start_dialogue(path_to_dialogue_sequence)
	else: dialogue_manager.start_dialogue("res://scenes/ui/dialogue/default.json")
	await  dialogue_manager.dialogue_ended
	if animation_after:
		if animation_after.has_animation("new_animation"):
			get_tree().paused = true
			var tmp1 = animation_after.process_mode
			var tmp2 = dialogue_manager.room.party_node.process_mode
			animation_after.process_mode = Node.PROCESS_MODE_ALWAYS
			dialogue_manager.room.party_node.process_mode = Node.PROCESS_MODE_ALWAYS
			animation_after.play("new_animation")
			await animation_after.animation_finished
			animation_after.process_mode = tmp1
			dialogue_manager.room.party_node.process_mode = tmp2
			dialogue_manager.room.party_node.end_being_controlled_by_animation()
			
	dialogue_manager.room.party_node.end_being_controlled_by_animation()
	get_tree().paused = false
func _on_area_entered(_body: Node2D) -> void:
	print_debug("dialogue area entered")
	dialogue_triggered.emit()
