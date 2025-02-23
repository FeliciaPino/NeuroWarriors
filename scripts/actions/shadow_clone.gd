extends BattleAction
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	action_name = "Shadow Clone"
	description = "Creates an identical shadow clone of the target that will fight for you"
	verb = "clone"
	isMelee = false
	isPositive = false
	price = 2
	animationType = "effect"
	_validate_values_are_initialized()

func execute (user:BattleEntity, target:BattleEntity):
	super.execute(user,target)
	_ranged_non_projectile_action()
const SHADOWSHADER = preload("res://assets/shaders/shadow.gdshader")
func _action_effect()->void:
	var entity_manager:EntityManager = user.game_manager.entity_manager
	#apparently using duplicate is a bit hacky. I'm not sure this entirye battle action should even exist. I'll keep it 'cause it's cool though
	var clone:BattleEntity = target.duplicate(DUPLICATE_SCRIPTS | DUPLICATE_GROUPS | DUPLICATE_SIGNALS) 
	clone.is_player_controlled = user.is_player_controlled
	
	entity_manager.spawn_entity(clone)
	var material = ShaderMaterial.new()
	material.shader = SHADOWSHADER
	clone.visual_node.material = material
