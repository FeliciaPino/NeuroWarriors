extends Node
@onready var game_manager = $".."

const FORMATIONS = [
	[],
	[Vector2(0.5,0.5)],
	[Vector2(0.4,0.6),Vector2(0.5,0.4)],
	[Vector2(0.3, 0.5), Vector2(0.5, 0.5), Vector2(0.7, 0.5)],
	[Vector2(0.25, 0.5), Vector2(0.4, 0.5), Vector2(0.6, 0.5), Vector2(0.75, 0.5)]
	#add more later
]
var entities:Array[BattleEntity] = []
var partyRect:Rect2 = Rect2(Vector2(100,600),Vector2(500,400))
var foesRect:Rect2 = Rect2(Vector2(600,600),Vector2(500,400))
func _ready() -> void:
	for child in get_children():
		if child is BattleEntity:
			entities.append(child)
	update_entities_formations()
			
#returns a list of all alive player-controlled characters
func get_party()->Array[BattleEntity]:
	return entities.filter(func(entity): return entity.is_player_controlled and entity.alive)
#returns a list of all alive foes
func get_foes()->Array[BattleEntity]:
	return entities.filter(func(entity): return not entity.is_player_controlled and entity.alive)

func _update_formation(team:Array[BattleEntity],rect:Rect2, mirror_x:bool = false)->void:
	var i:int = 0
	if team.size()>FORMATIONS.size():
		#there's no plan for this amount of entities! Chaos, chaos!
		for e in team:
			e.mySpot = Vector2(rect.position.x + randi()%int(rect.size.x), rect.position.y + randi()%int(rect.size.y))
		return
	for p in FORMATIONS[team.size()]:
		team[i].mySpot.x = rect.position.x + rect.size.x * ((1-p.x) if mirror_x else p.x)
		team[i].mySpot.y = rect.position.y + rect.size.y * p.y
		team[i].go_to_your_spot()
		i += 1
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
	else:
		entity.global_position = Vector2(window_size.x+200,window_size.y/2)#assuming window width is 1152
	update_entities_formations()
	
	
