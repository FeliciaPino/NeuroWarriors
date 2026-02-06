#this script is like 80% vibe coded. but it's not going into the game anyway so it doesn't matter

@tool
extends Node2D
@export var rebuild_map := false:
	set(value):
		if value:
			_rebuild()
			rebuild_map = false
# Keeps track of already-instanced rooms
var instantiated_rooms := {} # scene_path -> Room instance
# Tweakable spacing multiplier
@export var door_offset_scale := 6.0
const line_color := Color(1,0.6,0.6,0.8) 
const line_width := 15.0
var connection_lines := []
func _draw() -> void:
	for line_data in connection_lines:
		var from_pos:Vector2 = line_data.from.global_position
		var to_pos:Vector2 = line_data.to.global_position
		draw_line(from_pos, to_pos, line_color, line_width)
		var direction:Vector2 = (to_pos-from_pos).normalized()
		draw_circle(from_pos + direction*400,line_width*2, line_color)
func _ready() -> void:
	if Engine.is_editor_hint():
		set_process(true)
	else:
		return
	_build_map()
func _rebuild():
	
	_clear_map()
	await get_tree().process_frame
	_build_map()
func _clear_map():
	for child in get_children():
		if child is Room:
			child.set_meta("handled_connection", false)
	instantiated_rooms.clear()
	connection_lines.clear()
func _build_map():
	print("building map")
	for child in get_children():
		if child is Room:
			instantiated_rooms[child.scene_file_path] = child

	await get_tree().process_frame

	for child in get_children():
		if child is Room:
			await _expand_room(child)

func _expand_room(room: Room) -> void:
	print("attempting to expand",room.name)
	if room.get_meta("handled_connection",false):
		print("connectiong already handled")
		return
	room.set_meta("handled_connection", true)
	print("expanding room ",room.name)
	var passages := room.get_node_or_null("Passages")
	if passages == null:
		return

	for passage in passages.get_children():
		if passage is Passage:
			await _handle_connection(room, passage)
func _handle_connection(from_room: Room, passage: Passage) -> void:
	
	if passage.scene_path == "":
		return

	var target = instantiated_rooms.get(passage.scene_path)

	if target == null:
		var packed := load(passage.scene_path)
		if not packed:
			return

		target = packed.instantiate()
		add_child(target)
		target.owner = get_tree().edited_scene_root
		instantiated_rooms[passage.scene_path] = target

	await get_tree().process_frame
	_add_connection_line(passage, target)
	if !target.get_meta("handled_connection",false):
		_position_room(from_room, passage, target)
		await _expand_room(target)
func _position_room(from_room: Room, passage: Passage, new_room: Room) -> void:
	print("positioning room ",new_room.name)
	var from_door_pos := passage.position
	var from_door_delta := passage.collision_area.position
	# Find the arrival passage in the new room
	var arrival_passage := new_room.get_node_or_null("Passages").get_node_or_null(
		passage.arriving_passage_name
	)

	if arrival_passage == null:
		push_warning(
			"Arrival passage '%s' not found in %s"
			% [passage.arriving_passage_name, new_room.scene_file_path]
		)
		return

	var arrival_door_pos = arrival_passage.position

	# Direction from room A's door
	var direction := from_door_delta.normalized()
	await get_tree().process_frame

	# Offset so doors face each other
	var offset := direction * door_offset_scale * 64.0
	await get_tree().process_frame
	# Move new room so its arrival door lines up
	new_room.global_position = from_room.global_position + offset +from_door_pos  - (arrival_door_pos)
	
func _add_connection_line(passage: Passage, to_room: Room) -> void:
	var arrival_passage := to_room.get_node_or_null("Passages").get_node_or_null(
		passage.arriving_passage_name
	)
	
	if arrival_passage == null:
		return
	
	connection_lines.append({
		"from": passage,
		"to": arrival_passage
	})
