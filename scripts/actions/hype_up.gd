extends BattleAction

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	effect_duration = 2
	action_name = tr("BATTLE_ACTION_HYPE_UP_NAME")
	description = tr("BATTLE_ACTION_HYPE_UP_DESCRIPTION").format({status_effect_name=tr("STATUS_EFFECT_HYPED_NAME"),turn_amount=effect_duration})
	verb = tr("BATTLE_ACTION_HYPE_UP_VERB")
	isMelee = false
	isPositive = true
	price = 2
	animationType = "effect"
	_validate_values_are_initialized()
	
const hyped_status_effect_scene = preload("res://scenes/status_effects/hyped.tscn")
func execute (user:BattleEntity, target:BattleEntity):
	super.execute(user,target)
	_ranged_non_projectile_action()
func _action_effect()->void:
	var effect:StatusEffect = hyped_status_effect_scene.instantiate()
	effect.intensity = 10
	effect.set_turns_remaining(effect_duration)
	target.add_effect(effect)
