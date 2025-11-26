extends BattleAction
# Called when the node enters the scene tree for the first time.
var poisoned_effect = preload("res://scenes/status_effects/poisoned.tscn")

func _ready() -> void:
	super._ready()
	effect_duration = 4
	action_name = tr("BATTLE_ACTION_POISON_DART_NAME")
	description = tr("BATTLE_ACTION_POISON_DART_DESCRIPTION").format({turn_amount=effect_duration,amount=5})
	verb = tr("BATTLE_ACTION_POSION_DART_VERB")
	isMelee = false
	isPositive = false
	price = 4
	animationType = "throw"
	_validate_values_are_initialized()

func execute (user:BattleEntity, target:BattleEntity):
	super.execute(user,target)
	_projectile_action(600)
	
func _action_effect()->void:
	var effect:StatusEffect = poisoned_effect.instantiate()
	effect.intensity = user.attack
	effect.turns_remaining = effect_duration
	target.add_effect(effect)
	target.receive_damage(5)
