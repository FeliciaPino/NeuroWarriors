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
enum Side{LEFT, RIGHT}
func _set_speaker(speaker:String, side):
	var portrait
	if side == Side.LEFT:
		portrait = left_speaker_portrait
		left_speaker = speaker
	else:
		portrait = right_speaker_portrait
		right_speaker = speaker
	portrait.visible = true
	portrait.texture.atlas = sprites[speaker]
	var tween = create_tween().set_parallel(true)
	tween.tween_property(portrait,"modulate",Color(1,1,1,1),0.1)
	tween.tween_property(portrait, "scale", Vector2(1,1), 0.1)
	tween.tween_property(portrait,"position",Vector2(0,-20),0.1).set_ease(Tween.EASE_OUT)
	tween.set_parallel(false)
	tween.tween_property(portrait,"position",Vector2(0,0),0.1).set_ease(Tween.EASE_IN)
func _dim_speaker(side):
	var portrait
	if side == Side.LEFT:
		portrait = left_speaker_portrait
	if side == Side.RIGHT:
		portrait = right_speaker_portrait
	var tween = create_tween().set_parallel()
	tween.tween_property(portrait,"position",Vector2(0,40),0.2)
	tween.tween_property(portrait,"scale",Vector2(0.9,0.9),0.2)
	tween.tween_property(portrait,"modulate",Color(0.7,0.7,0.7),0.2)
	
func display_line(speaker:String, expression:String, text:String):
	active_speaker = speaker
	if speaker=="Narrator":
		left_speaker_portrait.visible = false
		left_speaker = ""
		right_speaker = ""
		right_speaker_portrait.visible = false
	elif "" == left_speaker and "" == right_speaker:
		if active_speaker in CharacterDatabase.ALL_CHARACTERS:
			_set_speaker(active_speaker,Side.LEFT)
		else:
			_set_speaker(active_speaker,Side.RIGHT)
	elif active_speaker == left_speaker:
		_set_speaker(active_speaker, Side.LEFT)
		_dim_speaker(Side.RIGHT)
	elif  active_speaker == right_speaker:
		_set_speaker(active_speaker, Side.RIGHT)
		_dim_speaker(Side.LEFT)
	elif "" == left_speaker and "" != right_speaker:
		_set_speaker(active_speaker, Side.LEFT)
		_dim_speaker(Side.RIGHT)
	elif "" != left_speaker and "" == right_speaker:
		_set_speaker(active_speaker, Side.RIGHT)
		_dim_speaker(Side.LEFT)
		
	#TODO: set the expression
	
	label.text = text
func clear():
	left_speaker = ""
	right_speaker = ""
	left_speaker_portrait.visible = false
	right_speaker_portrait.visible = false
	
