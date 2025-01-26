extends BattleAction

func _ready():
	action_name = "Katana Slash"
	description = "Cool katana slash to obliterate you oponents"
	verb = "attack"
	isMelee = true
	isPositive = false
	price = 4

func execute (user:BattleEntity, target:BattleEntity):
	super.execute(user,target)
	#generic punched
	#move_to(user,target.global_position-Vector2(100,0))
	var animation_player = user.get_node("BattleEntityAnimationPlayer")
	var animation = animation_player.get_animation("meele_attack")
	#ok, the position track of melee_attack has to be the first one
	animation.track_set_key_value(0,0,user.global_position)
	animation.track_set_key_value(0,1,target.global_position-Vector2(100,0))
	var initial_position = user.global_position
	animation_player.play("meele_attack")
	await animation_player.animation_finished
	
	target.receive_damage(user.attack*3.5)
	
	
	animation = animation_player.get_animation("walk_to")
	animation.track_set_key_value(0,0,user.global_position)
	animation.track_set_key_value(0,1,initial_position)
	animation.track_set_key_value(1,0,initial_position.x < user.global_position.x)
	animation_player.play("walk_to")
	await animation_player.animation_finished

	action_finished.emit()
	
