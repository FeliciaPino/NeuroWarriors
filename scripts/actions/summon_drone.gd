extends BattleAction
# Called when the node enters the scene tree for the first time.
const drone_scene = preload("res://scenes/characters/enemies/drone.tscn")
const offensive_drone_scene = preload("res://scenes/characters/enemies/offensive_drone.tscn")
const defensive_drone_scene = preload("res://scenes/characters/enemies/defensive_drone.tscn")
const healing_drone_scene = preload("res://scenes/characters/enemies/healing_drone.tscn")
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
	var random_number = randi()%100
	var new_guy:BattleEntity
	if random_number<= 40:
		new_guy = drone_scene.instantiate()
	elif random_number <= 65:
		new_guy = offensive_drone_scene.instantiate()
	elif random_number <= 80:
		new_guy = defensive_drone_scene.instantiate()
	else:
		new_guy = healing_drone_scene.instantiate()
	user.game_manager.entity_manager.spawn_entity(new_guy)
