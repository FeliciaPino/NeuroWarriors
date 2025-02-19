extends Node

const CHARACTER_SCENE_PATHS = {
	"Neuro-sama":"res://scenes/characters/neuro_sama.tscn",
	"Vedal":"res://scenes/characters/vedal.tscn",
	"Evil":"res://scenes/characters/evil.tscn"
}

func get_entity_scene(name:String) -> PackedScene:
	return load(CHARACTER_SCENE_PATHS[name])
