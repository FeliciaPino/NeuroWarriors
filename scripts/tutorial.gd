extends Label


var texts:Array[String]
var positions:Array[Vector2] = [
	Vector2(200,160),
	Vector2(360,20),
	Vector2(230,140),
	Vector2(720,80),
	Vector2(600,400),
	Vector2(360,20)
	]


@onready var entity_manager:EntityManager = $"../Entity_manager"
@onready var game_manager:GameManager = $".."
@onready var timer:Timer = $Timer
@onready var short_timer:Timer = $ShortTimer
var neuro_sama:BattleEntity = null
var index = 0
func _ready() -> void:
	texts = [
	tr("TUTORIAL_1"),
	tr("TUTORIAL_2"),
	tr("TUTORIAL_2_B"),
	tr("TUTORIAL_3"),
	tr("TUTORIAL_4"),
	tr("TUTORIAL_5")
	]
	
	position = positions[0]
	text = texts[0]
	short_timer.timeout.connect(_short_timer_timeout)
	game_manager.selected_action_changed.connect(_a_neuro_button_got_clicked)
	game_manager.player_turn_ended.connect(_on_player_turn_ended)
	game_manager.all_actions_finished.connect(_on_action_finished)
	find_neuro()
func find_neuro():
	var found_her = false
	for e in entity_manager.get_party():
		if e.entity_name=="Neuro-sama":
			found_her = true
			e.got_clicked_on.connect(_neuro_got_clicked_on)
			neuro_sama = e
			
	if not found_her:
		await get_tree().process_frame
		find_neuro()
func _neuro_got_clicked_on():
	if index==0:
		advance()
		timer.start()
func _a_neuro_button_got_clicked():
	print(str(self,": neuro button got clicked"))
	if index==1:
		if timer.time_left > timer.wait_time - 2:
			advance(2)
			short_timer.start()
		else:
			advance(3)
func _short_timer_timeout():
	if index==2:
		advance(3)
func _on_action_finished():
	if index<=3 and neuro_sama.ap!=3:
		advance(4)
func _on_player_turn_ended():
	if index == 3:
		pass
		#advance(4)
func advance(new_index=-1):
	if new_index==-1:
		index += 1
	else:
		index = new_index
	if index >= texts.size():
		queue_free()
		return
	position = positions[index]
	text = texts[index]


func _on_monocopter_got_clicked_on() -> void:
	if index==4:
		advance()
