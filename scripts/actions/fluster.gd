extends BattleAction
# Called when the node enters the scene tree for the first time.}

func _ready() -> void:
	super._ready()
	effect_duration = 4
	action_name = tr("BATTLE_ACTION_FLUSTER_NAME")
	description = tr("BATTLE_ACTION_FLUSTER_DESCRIPTION")
	verb = tr("BATTLE_FLUSTER_DART_VERB")
	isMelee = false
	isPositive = false
	price = 3
	animationType = "effect"
	_validate_values_are_initialized()

func execute (user:BattleEntity, target:BattleEntity):
	super.execute(user,target)
	_projectile_action(600)
const flushed_status_scene = preload("res://scenes/status_effects/flushed.tscn")
func _action_effect()->void:
	var effect:StatusEffect = flushed_status_scene.instantiate()
	effect.intensity = 5
	effect.turns_remaining = effect_duration
	target.add_effect(effect)
