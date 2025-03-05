extends BattleAction
# Called when the node enters the scene tree for the first time.}

func _ready() -> void:
	super._ready()
	effect_duration = 4
	action_name = tr("BATTLE_ACTION_FLUSTER_NAME")
	description = tr("BATTLE_ACTION_FLUSTER_DESCRIPTION")
	verb = tr("BATTLE_ACTION_FLUSTER_VERB")
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
	print(str(self,": attemtping to fluster ",target.entity_name))
	if user.entity_name=="Anny" and (target.entity_name=="Neuro-sama" or target.entity_name=="Evil"):
		print(str(self,": target is immune"))
		target.throw_text("Immune",Color.DARK_GRAY,1.5)
		return
	if user.entity_name=="Anny" and target.entity_name=="Vedal":
		user.throw_text("V- V- Vedal kun~", Color.DEEP_PINK,1.2)
	var effect:StatusEffect = flushed_status_scene.instantiate()
	effect.intensity = 5
	effect.turns_remaining = effect_duration
	target.add_effect(effect)
