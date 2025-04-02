extends HBoxContainer

@export var xp_added = 0 #set from outside
var leveled_up:bool = false #set from outside
@export var associated_character:String = "" #set from outside
@onready var xp_added_label = $Panel/Label
@onready var level_label = %LevelLabel
@onready var progress_bar:TextureProgressBar = $trail/progress
@onready var trailing_bar:TextureProgressBar = $trail
@onready var texture_rect = $PanelContainer/TextureRect
func _process(_delta):
	if xp_added_label:
		if xp_added_label.text != tr("BATTLE_LEVELED_UP"):
			xp_added_label.text = str("+",xp_added,"XP")
	$Panel2.custom_minimum_size.x = level_label.size.x
func _ready():
	get_tree().create_timer(0.8+get_index()*0.5).timeout.connect(decrease_xp_added_number)
	if associated_character=="":
		print(str(self,": ERROR! Character not set"))
		return
	
	var new_texture:AtlasTexture = AtlasTexture.new()
	new_texture.atlas = load("res://assets/overworld/overworld_"+associated_character+".png")
	new_texture.region = Rect2(0,0,32,32)
	texture_rect.texture = new_texture
	var current_character_level:int = GameState.characters_save_info[associated_character]["level"]
	if leveled_up: current_character_level -= 1
	level_label.text = str("LV",current_character_level)
	progress_bar.max_value = CharacterDatabase.xp_needed_to_level_up(GameState.characters_save_info[associated_character]["level"])+3
	trailing_bar.max_value = progress_bar.max_value
	
	trailing_bar.value = GameState.characters_save_info[associated_character]["experience"]
	if leveled_up:
		trailing_bar.value += trailing_bar.max_value
	progress_bar.value = trailing_bar.value - xp_added
	
func update_level_label():
	level_label.text = str("LV",GameState.characters_save_info[associated_character]["level"])
	
func decrease_xp_added_number():
	var tween = get_tree().create_tween().set_parallel()
	tween.tween_property(self,"xp_added",0,1.0)
	tween.tween_property(progress_bar,"value",trailing_bar.value,1.0)
	await tween.finished
	if leveled_up:
		xp_added_label.text = tr("BATTLE_LEVELED_UP")
		progress_bar.value = 0
		$AnimationPlayer.play("Level Up")
		$AudioStreamPlayer.play()
	else:
		xp_added_label.queue_free()
	
	
