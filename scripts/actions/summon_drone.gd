extends BattleAction
# Called when the node enters the scene tree for the first time.
var drone_scene = preload("res://scenes/characters/enemies/drone.tscn")
func _ready() -> void:
	super._ready()
	action_name = "Summon drone"
	description = "Summons an enemy drone."
	verb = "summon"
	isMelee = false
	isPositive = true
	price = 8
	animationType = "effect"
	_validate_values_are_initialized()

func execute (user:BattleEntity, target:BattleEntity):
	super.execute(user,target)
	_ranged_non_projectile_action(user,target)
func _action_effect(user:BattleEntity, target:BattleEntity)->void:
	user.game_manager.entity_manager.spawn_entity(drone_scene.instantiate())
