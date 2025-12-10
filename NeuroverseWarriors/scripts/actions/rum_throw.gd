extends BattleAction
# Called when the node enters the scene tree for the first time.
var poisoned_effect = preload("res://scenes/status_effects/poisoned.tscn")

func _ready() -> void:
	super._ready()
	action_name = tr("BATTLE_ACTION_RUM_THROW_NAME")
	description = tr("BATTLE_ACTION_RUM_THROW_DESCRIPTION").format({multiplier=action_multiplier,stat=tr("BATTLESTAT_ATTACK"), turn_amount=effect_duration})
	verb = tr("BATTLE_ACTION_RUM_THROW_VERB")
	animationType = "throw"
	_validate_values_are_initialized()

func execute (user:BattleEntity, target:BattleEntity):
	super.execute(user,target)
	_projectile_action(600)
	
func _action_effect()->void:
	var effect:StatusEffect = poisoned_effect.instantiate()
	effect.intensity = effect_intensity
	effect.turns_remaining = effect_duration
	target.add_effect(effect)
	if target.entity_name == "Vedal":
		target.heal(20)
		return
	target.receive_damage(user.attack*action_multiplier)
