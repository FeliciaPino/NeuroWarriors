extends Label
var texts:Array[String] = [
	"Click on a character to display their action menu. ",
	"At the start of each turn, a character gains a certain amount of Action Points (AP for short) You can use action points to make characters perform actions on any target you choose.
	Hover over an action to see the description
At any point you may end your turn.",
	"Enemies are the same.",
	"AP is not lost over turns. Try saving up to make powerful attacks or combos",
	""
	]
var positions:Array[Vector2] = [
	Vector2(164,310),
	Vector2(152,152),
	Vector2(617,270),
	Vector2(382,382),
	Vector2()
	]

var index = 0
func _ready() -> void:
	position = positions[0]
	text = texts[0]
	$Timer.timeout.connect(func():advance())
func advance():
	index += 1
	if index >= texts.size(): queue_free()
	if index == 2:
		$Timer.start()
	position = positions[index]
	text = texts[index]
	


func _on_neuro_sama_got_clicked_on() -> void:
	if index<=0: advance()


func _on_end_turn_button_pressed() -> void:
	if index == 1 or index==3: advance()
