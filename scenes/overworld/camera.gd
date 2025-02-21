extends Camera2D
@export var target:OverworldCharacter
func _process(delta: float) -> void:
	global_position = lerp(global_position,target.global_position,0.02)
