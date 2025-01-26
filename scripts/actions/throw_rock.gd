extends BattleAction

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	action_name = "Throw rock"
	description = "does damage from a distance"
	verb = "throw a rock at"
	isMelee = false
	isPositive = false
	price = 1

func execute (user:BattleEntity, target:BattleEntity):
	super.execute(user,target)
	
	var animation_player = user.get_node("BattleEntityAnimationPlayer")
	animation_player.play("throw")
	await animation_player.animation_finished
	if not target:
		action_finished.emit()
		return
	target.receive_damage(user.attack+3)
	
	action_finished.emit()
