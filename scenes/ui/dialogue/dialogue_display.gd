extends Control

@onready var label:Label = %Label
@onready var speaker_portrait = $MarginContainer/TextureRect

var sprites = {
	"Neuro-sama":preload("res://scenes/ui/dialogue/Neuro-sama_dialogue_sprites.png"),
	"Vedal":preload("res://scenes/ui/dialogue/Vedal_dialogue_sprites.png")
	}
func display_line(speaker:String, expression:String, text:String):
	if speaker=="Narrator":
		speaker_portrait.visible = false
	else:
		speaker_portrait.visible = true
		speaker_portrait.texture = sprites[speaker]
	
	label.text = text
