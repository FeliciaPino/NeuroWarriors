extends Node
class_name StatusEffect
var effect_name:String
var turns_remaining:int
var affected:BattleEntity
var intensity:int #only change intensity before applying the effect
@onready var turns_remaining_label:Label = $icon/turns_remaining_label
@onready var icon:TextureRect = $icon
func set_affected(entity:BattleEntity):
	affected = entity
func set_turns_remaining(value:int)->void:
	turns_remaining = value
	update_label()
func get_description():
	return "woopsie poopsie, forgor to overwrite get_description"
func update_label()->void:
	if turns_remaining_label and icon:
		turns_remaining_label.text = str(turns_remaining,"⌛")
		icon.tooltip_text = get_description()
	else:
		#In case the label or icon is not ready yet try again later.
		call_deferred("update_label")
func start_of_turn():
	set_turns_remaining(turns_remaining-1)
func start_effect():
	update_label()
	pass
func end_effect():
	pass
