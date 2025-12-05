extends Control

@export var always_visible:bool = false
@onready var label:Label = %Label
@onready var icon = %Icon
@onready var audio_player:AudioStreamPlayer = $AudioStreamPlayer
@onready var display_amount = GameState.get_tungesten_amount()
const small_tc_sprite:Texture2D = preload("res://assets/ui/tungesten_cubes_small.png")
func _ready() -> void:
	if !always_visible: modulate.a = 0
func _process(_delta) -> void:
	label.text = str(int(display_amount))
func spawn_tungesten(spawn_pos:Vector2, amount:int):
	if amount <= 0:
		return
	_spawn_tc_shower(spawn_pos,split_into_cubes(amount))
const DENOMS := [1,8,27,64,125]
#So, to get a bit more variaty in the types of cubes that pop out, i'll only go adding the bigger ones with larger totals. get the idea?
const INTRO_THRESHOLDS := {
	1: 0,
	8: 8,     # start showing 2x2 from total >= 8
	27: 30,   # start showing 3x3 from total >= 30
	64: 90,   # start showing 4x4 from total >= 90
	125: 200, # start showing 5x5 from total >= 200
}
func get_allowed_denoms(amount:int) -> Array[int]:
	var result:Array[int] = []
	for d in DENOMS:
		if amount > INTRO_THRESHOLDS[d]:
			result.append(d)
	return result
func split_into_cubes(amount:int) -> Array[int]:
	var remaining:=amount
	var result:Array[int] = []
	var denoms := get_allowed_denoms(amount)
	#biggest to smallest
	denoms.sort()
	denoms.reverse()
	for d in denoms:
		if remaining<= 0:
			break
		var count := remaining/d
		for i in count:
			result.append(d)
		remaining -= d*count
	#fill with 1s if theres's any leftover
	for i in remaining:
		result.append(1)
	return result
func _spawn_tc_shower(spawn_pos:Vector2, values:Array[int]):
	var modulate_tween = create_tween()
	modulate_tween.tween_property(self,"modulate:a",1,0.3)
	modulate_tween.tween_interval(2)
	if !always_visible: modulate_tween.tween_property(self,"modulate:a",0,0.3)
	get_tree().create_timer(3).timeout.connect(func():display_amount=GameState.get_tungesten_amount())
	for val in values:
		var cube = TextureRect.new()
		cube.z_index = 1
		add_child(cube)
		cube.texture = AtlasTexture.new()
		cube.texture.atlas = small_tc_sprite
		var index:int = int(round(pow(float(val), 1.0 / 3.0)))-1
		clamp(index,0,4)
		cube.texture.region = Rect2(32*index,0,32,32)
		cube.global_position=spawn_pos
		var goal_pos = Vector2(spawn_pos.x + (randf()-0.5)*randfn(120,15),randfn(spawn_pos.y,15))
		var duration = 0.6
		var tween = create_tween()
		tween.tween_property(cube,"global_position:x",(goal_pos.x+spawn_pos.x)/2,duration/2).set_trans(tween.TRANS_LINEAR) 
		tween.set_parallel()
		tween.tween_property(cube,"global_position:y",goal_pos.y-max(randfn(60,10),0)-10,duration/2).set_trans(tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.set_parallel(false)
		tween.tween_property(cube,"global_position:x",goal_pos.x,duration/2).set_trans(tween.TRANS_LINEAR)
		tween.set_parallel()
		tween.tween_property(cube,"global_position:y",goal_pos.y,duration/2).set_trans(tween.TRANS_QUAD).set_ease(Tween.EASE_IN) 
		tween.set_parallel(false)
		tween.tween_interval(max(randfn(0.08,0.02)*float(values.size()),0)+0.1)
		tween.tween_property(cube,"position:x",-16,0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		tween.set_parallel()
		tween.tween_property(cube,"position:y",-16,0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
		tween.finished.connect(_add_tungesten.bind(val))
		tween.finished.connect(cube.queue_free)
func _add_tungesten(amount):
	display_amount += amount
	var tween = create_tween()
	icon.scale = Vector2(1.1,1.1)
	tween.tween_property(icon,"scale",Vector2(1,1),0.05).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT) 
	audio_player.pitch_scale = randfn(0.7,0.2)
	audio_player.play()
	
