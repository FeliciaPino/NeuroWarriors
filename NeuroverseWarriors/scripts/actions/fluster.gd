extends BattleAction
# Called when the node enters the scene tree for the first time.}

func _ready() -> void:
	super._ready()
	action_name = tr("BATTLE_ACTION_FLUSTER_NAME")
	description = tr("BATTLE_ACTION_FLUSTER_DESCRIPTION")
	verb = tr("BATTLE_ACTION_FLUSTER_VERB")

const flushed_status_scene = preload("res://scenes/status_effects/flushed.tscn")
func _action_effect()->void:
	print_debug(str(self,": attemtping to fluster ",current_target.entity_name))
	if user.entity_name=="Anny" and (current_target.entity_name=="Neuro-sama" or current_target.entity_name=="Evil"):
		print_debug(str(self,": target is immune"))
		current_target.throw_text("Immune",Color.DARK_GRAY,1.5)
		return
	if user.entity_name=="Anny" and current_target.entity_name=="Vedal":
		user.throw_text("V- V- Vedal kun~", Color.DEEP_PINK,1.2)
	var effect:StatusEffect = flushed_status_scene.instantiate()
	effect.intensity = effect_intensity
	effect.turns_remaining = effect_duration
	current_target.add_effect(effect)
