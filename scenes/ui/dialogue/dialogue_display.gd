extends Control


@onready var label:RichTextLabel = %RichTextLabel
@onready var left_speaker_portrait:TextureRect = %LeftSpeaker
@onready var left_speaker_name := %NameLabelLeft
@onready var right_speaker_portrait:TextureRect = %RightSpeaker
@onready var right_speaker_name := %NameLabelRight
@onready var dialogue_bleeps:AudioStreamPlayer = %DialogueBleeps
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
	},
	"Evil":{
		"Neutral":preload("res://scenes/ui/dialogue/portraits/Evil/Neutral.png")
	}
}
const voices ={
	"Neuro-sama":preload("res://assets/audio/homemade/clips/neuro_blip.mp3"),
	"Vedal":preload("res://assets/audio/homemade/clips/vedal_blip.mp3"),
	"Evil":preload("res://assets/audio/homemade/clips/evil_blip.mp3"),
	"Narrator":preload("res://assets/audio/homemade/SFX/narrator_blip.mp3")
}
	
enum Side{LEFT, RIGHT}

const DEFAULT_TYPING_SPEED = 30.0
var typing_speed = DEFAULT_TYPING_SPEED
var text_tween:Tween = null

	
var previous_label_visible_characters = 0
func _process(delta: float) -> void:
	if label.visible_characters != previous_label_visible_characters:
		if label.get_parsed_text()[label.visible_characters-1] != ' ':
			dialogue_bleeps.pitch_scale = 0.9 + randf()/5.0
			dialogue_bleeps.play()
	previous_label_visible_characters = label.visible_characters
func _hide_screen(side):
	if side == Side.LEFT:
		$MarginContainer/LeftSpeakerControl/ScreenBackgroundBack.visible = false
		$MarginContainer/LeftSpeakerControl/ScreenBackgroundFront.visible = false
		$MarginContainer/LeftSpeakerControl/ScreenOutline.visible = false
	else:
		$MarginContainer/RightSpeakerControl/ScreenBackgroundBack.visible = false
		$MarginContainer/RightSpeakerControl/ScreenBackgroundFront.visible = false
		$MarginContainer/RightSpeakerControl/ScreenOutline.visible = false
func _show_screen(side):
	if side==Side.LEFT:
		$MarginContainer/LeftSpeakerControl/ScreenBackgroundBack.visible = true
		$MarginContainer/LeftSpeakerControl/ScreenBackgroundFront.visible = true
		$MarginContainer/LeftSpeakerControl/ScreenOutline.visible = true
	else:
		$MarginContainer/RightSpeakerControl/ScreenBackgroundBack.visible = true
		$MarginContainer/RightSpeakerControl/ScreenBackgroundFront.visible = true
		$MarginContainer/RightSpeakerControl/ScreenOutline.visible = true

#This might seem trivial, but consider a playable character that's in the world before joining the party. This function might prove useful then
func is_character_in_the_room_with_us_now(character_name):
	return GameState.is_character_in_party(character_name)

func _set_speaker(speaker:String, expression:String, side):
	var portrait
	var name_label
	if side == Side.LEFT:
		portrait = left_speaker_portrait
		name_label = left_speaker_name
		left_speaker = speaker
	else:
		portrait = right_speaker_portrait
		name_label = right_speaker_name
		right_speaker = speaker
	portrait.visible = true
	name_label.visible = true
	name_label.text = tr(speaker)
	if is_character_in_the_room_with_us_now(speaker):
		_hide_screen(side)
	else:
		_show_screen(side)
	print_debug(str("setting expression ",expression," for ",speaker))
	portrait.texture = sprites[speaker].get(expression,sprites[speaker]["Neutral"])
	var tween = create_tween().set_parallel(true)
	tween.tween_property(portrait,"modulate",Color(1,1,1,1),0.1)
	tween.tween_property(portrait, "scale", Vector2(1,1), 0.1)
	tween.tween_property(portrait,"position",Vector2(0,-20),0.1).set_ease(Tween.EASE_OUT)
	tween.tween_property(name_label.get_parent(),"position:y",320,0.1)
	tween.set_parallel(false)
	tween.tween_property(portrait,"position",Vector2(0,0),0.1).set_ease(Tween.EASE_IN)
func _dim_speaker(side):
	var portrait
	var name_label
	if side == Side.LEFT:
		portrait = left_speaker_portrait
		name_label = left_speaker_name
	if side == Side.RIGHT:
		portrait = right_speaker_portrait
		name_label = right_speaker_name
	var tween = create_tween().set_parallel()
	tween.tween_property(portrait,"position",Vector2(0,40),0.2)
	tween.tween_property(portrait,"scale",Vector2(0.9,0.9),0.2)
	tween.tween_property(portrait,"modulate",Color(0.7,0.7,0.7),0.2)
	tween.tween_property(name_label.get_parent(),"position:y",380,0.1)
	
func display_line(speaker:String, expression:String, text:String):
	active_speaker = speaker
	if speaker=="Narrator":
		left_speaker_portrait.visible = false
		left_speaker = ""
		left_speaker_name.visible = false
		
		right_speaker_portrait.visible = false
		right_speaker = ""
		right_speaker_name.visible = false
		
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
	
	dialogue_bleeps.stream = voices.get(active_speaker,voices["Neuro-sama"])
	if text_tween:
		if text_tween.is_running():
			text_tween.stop()
	text_tween = create_tween()
	label.parse_bbcode(text)
	label.visible_characters = 0
	text_tween.tween_property(label,"visible_characters",label.get_parsed_text().length(),float(label.get_parsed_text().length())/typing_speed)
func show_whole_text():
	if text_tween:
		text_tween.stop()
	label.visible_ratio = 1.0
func is_whole_text_visible():
	var ans = true
	if text_tween:
		if text_tween.is_running():
			ans = false
	return ans
func clear():
	left_speaker = ""
	left_speaker_portrait.visible = false
	left_speaker_name.visible = false
	_hide_screen(Side.LEFT)
	right_speaker = ""
	right_speaker_portrait.visible = false
	right_speaker_name.visible = false
	_hide_screen(Side.RIGHT)
	
	
