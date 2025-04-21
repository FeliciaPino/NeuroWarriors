extends CharacterBody2D
class_name OverworldCharacter

@export var speed = 150


@export var associated_character:String = "":
	set(new_value):
		associated_character = new_value
		if is_inside_tree():
			update_sprite_frames_from_character_name(new_value)
@onready var sprite = $AnimatedSprite2D
@onready var collider = $CollisionShape2D
@onready var facer := $Facer
@export var following_target:OverworldCharacter = null
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
func _physics_process(delta: float) -> void:
	GameState.set_player_map_position(global_position)
	var direction  = Input.get_vector("left","right","up","down")
	velocity = direction*speed
	if following_target:
		var difference_to_target = (following_target.global_position - global_position)
		var distance_to_target = difference_to_target.length()
		if distance_to_target>25:
			velocity = difference_to_target.normalized()*((distance_to_target-24)*15+1)
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
	
