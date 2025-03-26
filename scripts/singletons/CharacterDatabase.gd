extends Node

const CHARACTER_SCENE_PATHS = {
	"Neuro-sama":"res://scenes/characters/neuro_sama.tscn",
	"Vedal":"res://scenes/characters/vedal.tscn",
	"Evil":"res://scenes/characters/evil.tscn",
	"Anny":"res://scenes/characters/anny.tscn"
}
const ALL_CHARACTERS = [
	"Neuro-sama",
	"Vedal",
	"Evil",
	"Anny"
]

func get_entity_scene(name:String) -> PackedScene:
	print(str(self,": loading ",name))
	return load(CHARACTER_SCENE_PATHS[name])
