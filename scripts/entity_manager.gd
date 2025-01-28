extends Node
@onready var game_manager = $".."

const FORMATIONS = [
	[],
	[Vector2(0.7,0.5)],
	[Vector2(0.7,0.3),Vector2(0.5,0.8)],
	[Vector2(0.8, 0.3), Vector2(0.6, 0.8), Vector2(0.4, 0.2)],
	[Vector2(0.85, 0.3), Vector2(0.7, 0.8), Vector2(0.55, 0.2), Vector2(0.4,0.8)],
	#add more later
]
var entities:Array[BattleEntity] = []
@export var partyRect:Rect2 = Rect2(Vector2(50,400),Vector2(450,170))
@export var foesRect:Rect2 = Rect2(Vector2(600,400),Vector2(450,170))
func _ready() -> void:
	for child in get_children():
		if child is BattleEntity:
			entities.append(child)
			child.just_freaking_died_right_now.connect(func():remove_entity(child))
	update_entities_formations()
	
func remove_entity(entity:BattleEntity):
	entities.erase(entity)
	if entity.is_player_controlled:
		_update_formation(get_party(),partyRect)
	else:
		_update_formation(get_foes(),foesRect,true)
	game_manager.update_battle_entities()
#returns a list of all alive player-controlled characters
func get_party()->Array[BattleEntity]:
	return entities.filter(func(entity): return entity.is_player_controlled and entity.alive)
#returns a list of all alive foes
func get_foes()->Array[BattleEntity]:
	return entities.filter(func(entity): return not entity.is_player_controlled and entity.alive)
	
func _nudge_entites_from_eachother(enti:Array[BattleEntity],rect:Rect2):
	for e in enti:
		for ee in enti:
			if e == ee: continue
			var p1:Vector2 = e.mySpot
			var p2:Vector2 = ee.mySpot
			var repeller:Vector2 = (p1-p2).normalized()*5000/(p1.distance_squared_to(p2)+1)
			e.mySpot += repeller
			ee.mySpot -= repeller
			e.mySpot = e.mySpot.clamp(rect.position,rect.position+rect.size)
			ee.mySpot = ee.mySpot.clamp(rect.position,rect.position+rect.size)
			
func _random_formation(team:Array[BattleEntity],rect:Rect2):
		for e in team:e.mySpot = Vector2(rect.position.x + randi()%int(rect.size.x), rect.position.y + randi()%int(rect.size.y))
		for i in range(8):_nudge_entites_from_eachother(team,rect)
		for e in team: 
			e.go_to_your_spot()
func _update_formation(team:Array[BattleEntity],rect:Rect2, mirror_x:bool = false)->void:
	var i:int = 0
	if team.size()>=FORMATIONS.size():
		#there's no plan for this amount of entities! Chaos, chaos!
		_random_formation(team,rect)
		return
	for p in FORMATIONS[team.size()]:
		team[i].mySpot.x = rect.position.x + rect.size.x * ((1-p.x) if mirror_x else p.x)
		team[i].mySpot.y = rect.position.y + rect.size.y * p.y
		team[i].go_to_your_spot()
		i += 1
#I think this is deprecated. I mean, if an entity is added or removed we should only update it's side of the battlefield, no?
func update_entities_formations()->void:
	_update_formation(get_party(),partyRect)
	_update_formation(get_foes(),foesRect,true)
	
func spawn_entity(entity_scene:PackedScene, is_player_controlled:bool):
	var entity:BattleEntity = entity_scene.instantiate()
	entity.is_player_controlled = is_player_controlled
	self.add_child(entity)
	entities.append(entity)
	var window_size = DisplayServer.window_get_size()
	if is_player_controlled:
		entity.global_position = Vector2(-200,window_size.y/2)
		_update_formation(get_party(),partyRect)
	else:
		entity.global_position = Vector2(window_size.x+200,window_size.y/2)#assuming window width is 1152
		_update_formation(get_foes(),foesRect,true)
		
	
	
