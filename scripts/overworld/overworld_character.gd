extends CharacterBody2D
class_name OverworldCharacter

@export var speed = 150


@export var inspector_spriteframes:SpriteFrames#debug
@onready var sprite = $AnimatedSprite2D
@onready var collider = $CollisionShape2D

@export var following_target:OverworldCharacter = null
func _ready() -> void:
	print(str(self,": I am a character, getting ready"))
	global_position = GameState.get_player_map_position()
	if inspector_spriteframes != null:
		print(str(self,":setting sprite frames"))
		set_sprite_frames(inspector_spriteframes)
	else:
		print(str(self,":not setting sprite frames"))
	if following_target:
		print(str(self,":i am a follower, disabling collisions"))
		
		set_collision_layer_value(1, false)  
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
	move_and_slide()
	
