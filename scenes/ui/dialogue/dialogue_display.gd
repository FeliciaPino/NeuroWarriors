extends Control

@onready var label:Label = %Label
@onready var left_speaker_portrait:TextureRect = %LeftSpeaker
@onready var right_speaker_portrait:TextureRect = %RightSpeaker
var left_speaker:String = ""
var right_speaker:String = ""

var active_speaker:String = ""

var sprites = {
	"Neuro-sama":{
		"Neutral":preload("res://scenes/ui/dialogue/portraits/Neuro-sama/Neutral.png"),
		"Smug":preload("res://scenes/ui/dialogue/portraits/Neuro-sama/Smug.png"),
		"Confused":preload("res://scenes/ui/dialogue/portraits/Neuro-sama/Confused.png"),
		"Happy":preload("res://scenes/ui/dialogue/portraits/Neuro-sama/Happy.png")
	},
	"Vedal":{
		"Neutral":preload("res://scenes/ui/dialogue/portraits/Vedal/Neutral.png"),
		"Confused":preload("res://scenes/ui/dialogue/portraits/Vedal/Confused.png")
	}
}
	
enum Side{LEFT, RIGHT}
func _set_speaker(speaker:String, expression:String, side):
	var portrait
	if side == Side.LEFT:
		portrait = left_speaker_portrait
		left_speaker = speaker
	else:
		portrait = right_speaker_portrait
		right_speaker = speaker
	portrait.visible = true
	print_debug(str("setting expression ",expression," for ",speaker))
	portrait.texture = sprites[speaker].get(expression,sprites[speaker]["Neutral"])
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
			_set_speaker(active_speaker, expression, Side.LEFT)
		else:
			_set_speaker(active_speaker, expression,Side.RIGHT)
	elif active_speaker == left_speaker:
		_set_speaker(active_speaker, expression, Side.LEFT)
		_dim_speaker(Side.RIGHT)
	elif  active_speaker == right_speaker:
		_set_speaker(active_speaker, expression, Side.RIGHT)
		_dim_speaker(Side.LEFT)
	elif "" == left_speaker and "" != right_speaker:
		_set_speaker(active_speaker, expression, Side.LEFT)
		_dim_speaker(Side.RIGHT)
	elif "" != left_speaker and "" == right_speaker:
		_set_speaker(active_speaker, expression, Side.RIGHT)
		_dim_speaker(Side.LEFT)
		
	
	label.text = text
func clear():
	left_speaker = ""
	right_speaker = ""
	left_speaker_portrait.visible = false
	right_speaker_portrait.visible = false
	
