extends Node
class_name EntityManager

@onready var game_manager = $".."
const FORMATIONS = [
	[],
	[Vector2(0.7,0.5)], #1
	[Vector2(0.7,0.3),Vector2(0.5,0.8)], #2
	[Vector2(0.8, 0.3), Vector2(0.6, 0.8), Vector2(0.4, 0.2)], #3
	[Vector2(0.85, 0.3), Vector2(0.7, 0.8), Vector2(0.55, 0.2), Vector2(0.4,0.8)], #4
	[Vector2(0.85, 0.4), Vector2(0.7, 0.8), Vector2(0.6, 0.2), Vector2(0.4,0.8), Vector2(0.3,0.3)], #5
	[Vector2(0.85, 0.5), Vector2(0.65, 0.8), Vector2(0.65, 0.2), Vector2(0.45,0.8), Vector2(0.45,0.2), Vector2(0.25,0.5)], #6
	[Vector2(0.85, 0.5), Vector2(0.7, 0.8), Vector2(0.7, 0.2), Vector2(0.4,0.8), Vector2(0.4,0.2), Vector2(0.55,0.5), Vector2(0.3,0.5)], #7
	[Vector2(0.85, 0.5), Vector2(0.7, 0.8), Vector2(0.7, 0.2), Vector2(0.45,0.8), Vector2(0.45,0.2), Vector2(0.55,0.5), Vector2(0.3,0.5), Vector2(0.2,0.2)], #8
	[Vector2(0.85, 0.5), Vector2(0.7, 0.8), Vector2(0.7, 0.2), Vector2(0.45,0.8), Vector2(0.45,0.2), Vector2(0.55,0.5), Vector2(0.3,0.5), Vector2(0.2,0.2), Vector2(0.2,0.8)], #9
	[Vector2(0.85, 0.5), Vector2(0.7, 0.8), Vector2(0.7, 0.2), Vector2(0.45,0.8), Vector2(0.45,0.2), Vector2(0.55,0.5), Vector2(0.3,0.5), Vector2(0.2,0.2), Vector2(0.2,0.8), Vector2(0.05,0.5)]#10
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
	#Since we're removing it, have to give focus to one if it's neighbors
	for d in [SIDE_BOTTOM,SIDE_LEFT,SIDE_RIGHT,SIDE_TOP]:
		var possible_neighbor = get_node_or_null(entity.button.get_focus_neighbor(d))
		if possible_neighbor:
			possible_neighbor.grab_focus()
			break
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
			if not e.is_stationary: e.mySpot += repeller
			if not ee.is_stationary: ee.mySpot -= repeller
			e.mySpot = e.mySpot.clamp(rect.position,rect.position+rect.size)
			ee.mySpot = ee.mySpot.clamp(rect.position,rect.position+rect.size)
			
func _random_formation(team:Array[BattleEntity],rect:Rect2):
		seed(1)
		for e in team:
			if e.is_stationary: continue
			e.mySpot = Vector2(rect.position.x + randfn(0.5,0.1)*rect.size.x, rect.position.y + randfn(0.5,0.1)*rect.size.y)
		for i in range(8):_nudge_entites_from_eachother(team,rect)
		for e in team: 
			e.go_to_your_spot()
func _count_entities_for_formation(team:Array[BattleEntity]):
	var ans = 0
	for e in team:
		if not e.is_stationary:
			ans += 1
	return ans
func _update_formation(team:Array[BattleEntity],rect:Rect2, mirror_x:bool = false)->void:
	var e_count = _count_entities_for_formation(team)
	if e_count>=FORMATIONS.size():
		#there's no plan for this amount of entities! Chaos, chaos!
		_random_formation(team,rect)
		return
		
	var i:int = -1
	for e in team:
		if e.is_stationary: continue
		i += 1
		var p = FORMATIONS[e_count][i]
		e.mySpot.x = rect.position.x + rect.size.x * ((1-p.x) if mirror_x else p.x)
		e.mySpot.y = rect.position.y + rect.size.y * p.y
		e.go_to_your_spot()
		
func update_entities_formations()->void:
	_update_formation(get_party(),partyRect)
	_update_formation(get_foes(),foesRect,true)

#I should have probbbably made this based on their  spots rather than their dynamic positions. Oh well
func update_focus_neighbours()->void:
	var closest_to_end_turn_button:BattleEntity=entities[0]
	for node in entities:
		if not node.alive: continue
		if closest_to_end_turn_button.mySpot.distance_squared_to(game_manager.end_turn_buttton.global_position) > node.mySpot.distance_squared_to(game_manager.end_turn_buttton.global_position):
			closest_to_end_turn_button = node
		#up down left right neighbors, the closest node in that direction
		var neighbors:Array[BattleEntity] = [null,null,null,null]
		for other in entities:
			if other==node or not other.alive: continue
			var dy:int = other.mySpot.y - node.mySpot.y
			var dx:int = other.mySpot.x - node.mySpot.x
			var q = -1 #the quadrant the other node is
			if dy < dx and dy < -dx: q = 0 #up quadrant
			if dy > dx and dy > -dx: q = 1 #down quadrant
			if dy > dx and dy < -dx: q = 2 #left quadrant
			if dy < dx and dy > -dx: q = 3 #right quadrant
			if not neighbors[q]:
				neighbors[q] = other
			elif other.mySpot.distance_squared_to(node.mySpot) < neighbors[q].mySpot.distance_squared_to(node.mySpot):
				neighbors[q] = other
		
		if neighbors[0]: node.button.focus_neighbor_top = neighbors[0].button.get_path()
		if neighbors[1]: node.button.focus_neighbor_bottom = neighbors[1].button.get_path()
		else: node.button.focus_neighbor_bottom = game_manager.end_turn_buttton.get_path()
		if neighbors[2]: node.button.focus_neighbor_left = neighbors[2].button.get_path()
		if neighbors[3]: node.button.focus_neighbor_right = neighbors[3].button.get_path()
	#connect end turn button to closest entity (don't have to worry about direction sicnce the button is at the bottom already)
	game_manager.end_turn_buttton.focus_neighbor_top = closest_to_end_turn_button.button.get_path()
	
func spawn_entity(entity:BattleEntity, keep_position:bool = false):
	print_debug("Entity Spawner: spanwing: "+str(entity))
	self.add_child(entity)
	entities.append(entity)
	entity.set_up_at_start_of_turn()
	entity.just_freaking_died_right_now.connect(func():remove_entity(entity))
	var window_size = DisplayServer.window_get_size()
	if not keep_position:
		if entity.is_player_controlled:
			entity.global_position = Vector2(-50,window_size.y*0.4)
		else:
			entity.global_position = Vector2(window_size.x-100,window_size.y*0.4)
			
	if entity.is_player_controlled:
		_update_formation(get_party(),partyRect)
	else:
		_update_formation(get_foes(),foesRect,true)
	
		
	
	
