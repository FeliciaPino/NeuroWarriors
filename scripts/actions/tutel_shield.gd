extends BattleAction

var defense_effect = preload("res://scenes/status_effects/defense_up.tscn")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	action_name = "Tutel Shield"
	description = "Summon a shield to protect your allies for the next 3 turns"
	verb = "defend"
	isMelee = false
	isPositive = true
	price = 2
	

func execute (user:BattleEntity, target:BattleEntity):
	super.execute(user,target)
	
	var animation_player = user.get_node("BattleEntityAnimationPlayer")
	animation_player.play("effect")
	await animation_player.animation_finished
	if not target:
		action_finished.emit()
		return
		
	sprite.visible = true
	sprite.scale = Vector2(0.1,0.1)
	sprite.global_position = target.global_position
	var tween = get_tree().create_tween().set_parallel()
	tween.tween_property(sprite, "visible", false, 3)
	tween.tween_property(sprite,"rotation",3.14159*4,0.7)
	tween.tween_property(sprite,"scale",Vector2(1,1),0.7)
	

	var effect:StatusEffect = defense_effect.instantiate()
	effect.set_turns_remaining(3)
	effect.intensity = 10
	print("creating new effect: " + effect.effect_name)

	target.add_effect(effect)
	
	action_finished.emit()
func _action_effect(user:BattleEntity, target:BattleEntity)->void:
	var effect:StatusEffect = defense_effect.instantiate()
	effect.set_turns_remaining(3)
	effect.intensity = 10
	target.add_effect(effect)
