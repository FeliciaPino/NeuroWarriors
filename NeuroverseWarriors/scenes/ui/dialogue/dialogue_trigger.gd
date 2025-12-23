extends Node2D
class_name DialogueTrigger
signal dialogue_triggered

@onready var dialogue_manager:DialogueManager = %DialogueManager

@export var interactable_component:InteractableComponent
@export var area_trigger:Area2D

@export var path_to_dialogue_sequence:String

func _ready() -> void:
	for c in get_children():
		if c is InteractableComponent:
			interactable_component = c
		if c is Area2D:
			area_trigger = c
	if interactable_component:
		interactable_component.interacted.connect(dialogue_triggered.emit)
	if area_trigger:
		area_trigger.body_entered.connect(_on_area_entered)
	dialogue_triggered.connect(dialogue_manager.start_dialogue.bind(path_to_dialogue_sequence))

func _on_area_entered(_body: Node2D) -> void:
	print_debug("dialogue area entered")
	dialogue_triggered.emit()
