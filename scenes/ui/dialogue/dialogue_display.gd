extends Control

@onready var label:Label = %Label
@onready var left_speaker_portrait:TextureRect = %LeftSpeaker
@onready var right_speaker_portrait:TextureRect = %RightSpeaker
var left_speaker:String = ""
var right_speaker:String = ""

var active_speaker:String = ""

var sprites = {
	"Neuro-sama":preload("res://scenes/ui/dialogue/Neuro-sama_dialogue_sprites.png"),
	"Vedal":preload("res://scenes/ui/dialogue/Vedal_dialogue_sprites.png")
	}
func set_left_speaker(speaker:String):
	left_speaker_portrait.visible = true
	left_speaker = speaker
	left_speaker_portrait.texture = sprites[speaker]
func set_right_speaker(speaker:String):
	right_speaker_portrait.visible = true
	right_speaker = speaker
	right_speaker_portrait.texture = sprites[speaker]
func dim_speakers():
	right_speaker_portrait.visible = false
	left_speaker_portrait.visible = false
func display_line(speaker:String, expression:String, text:String):
	active_speaker = speaker
	dim_speakers()
	if speaker=="Narrator":
		left_speaker_portrait.visible = false
		right_speaker_portrait.visible = false
	elif "" == left_speaker and "" == right_speaker:
		if active_speaker in CharacterDatabase.ALL_CHARACTERS:
			set_left_speaker(active_speaker)
		else:
			set_right_speaker(active_speaker)
	elif active_speaker == left_speaker:
		set_left_speaker(active_speaker)
	elif  active_speaker == right_speaker:
		set_right_speaker(active_speaker)
	elif "" == left_speaker and "" != right_speaker:
		set_left_speaker(active_speaker)
	elif "" != left_speaker and "" == right_speaker:
		set_right_speaker(active_speaker)
		
	#TODO: set the expression
	
	label.text = text
