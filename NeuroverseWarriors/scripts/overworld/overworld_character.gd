extends CharacterBody2D
class_name OverworldCharacter

@export var speed = 150


@export var associated_character:String = "":
	set(new_value):
		associated_character = new_value
		if is_inside_tree():
			update_sprite_frames_from_character_name(new_value)
@onready var sprite := $AnimatedSprite2D
@onready var collider := $Body
@onready var facer := $Facer
@onready var interacter := $interacter #collider that detects interactions with the world (such as inspecting, activating something, or talking with an npc)
@export var following_target:Node2D = null
@export var follow_distance := 1.0
func _ready() -> void:
	print_debug(str(self,": set pos as ",global_position))
	if associated_character != "null":
		update_sprite_frames_from_character_name(associated_character)
	if following_target:
		set_collision_layer_value(1, false)  
		
func update_sprite_frames_from_character_name(character_name:String):
	set_sprite_frames(load("res://assets/overworld/"+character_name+"_spriteframes.tres"))
	
func set_sprite_frames(new_frames:SpriteFrames):
	sprite.sprite_frames = new_frames
	
func _physics_process(_delta: float) -> void:
	GameState.set_player_map_position(global_position)
	var direction  = Input.get_vector("left","right","up","down")
	if !get_tree().paused: velocity = direction*speed
	if following_target:
		var difference_to_target = (following_target.global_position - global_position)
		var distance_to_target = difference_to_target.length()
		if distance_to_target>follow_distance:
			var speedness = min((distance_to_target-follow_distance)*0.6/_delta+1.5,speed)
			velocity = difference_to_target.normalized()*speedness
		else:
			velocity = Vector2()
		if distance_to_target>80:
			global_position += difference_to_target/5
	elif velocity.length()>1:
		if abs(velocity.x) > abs(velocity.y):
			facer.facing = "e" if velocity.x > 0 else "w"
		else:
			facer.facing = "s" if velocity.y > 0 else "n"
	move_and_slide()
	
func _on_animated_sprite_2d_animation_changed() -> void:
	if "moving_w"==sprite.animation or "idle_w"==sprite.animation:
		interacter.position = Vector2(-16,5)
	if "moving_n"==sprite.animation or "idle_n"==sprite.animation:
		interacter.position = Vector2(0,-16)
	if "moving_e"==sprite.animation or "idle_e"==sprite.animation:
		interacter.position = Vector2(15,5)
	if "moving_s"==sprite.animation or "idle_s"==sprite.animation:
		interacter.position = Vector2(0,16)
		
