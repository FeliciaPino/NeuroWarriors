extends PassiveAbility
@export var damage := 4
func _ready() -> void:
	await super._ready()
	associated_entity.somebody_entered_my_personal_space.connect(_got_close)
func _got_close(entity:BattleEntity):
	entity.receive_damage(damage)
func get_description():
	return tr("PASSSIVE_ABILITY_SPIKY_DESCRIPTION").format({amount=damage})
