extends AudioStreamPlayer

var current_music:AudioStream = null
func _ready() -> void:
	bus = "Music"
	
func play_music(new_music:AudioStream, fade_time:float = 0.5):
	if new_music == current_music:
		return
	current_music = new_music
	await get_tree().create_tween().tween_property(self, "volume_db", -40, fade_time/2).finished
	stream = current_music
	play()
	get_tree().create_tween().tween_property(self, "volume_db",0,fade_time/2)
	
	
	
