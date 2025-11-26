extends Control
@onready var trailing_bar:TextureProgressBar = %"Trailing Bar"
@onready var progress_bar:TextureProgressBar = %"Progress Bar"
@onready var timer = $Timer
@onready var associated_entity:BattleEntity = $".."
@onready var effects_container := %StatusEffects
func setup(newMax:int, defense:int)->void:
	size.x = newMax*0.6+4 #add 4 to acount for the border
	if newMax > 500:
		effects_container.position.y += size.y-2
		size.y = (size.y-2)*2
		size.x = size.x/4
		progress_bar.min_value = -8 
	position.x = int(-size.x/2)
	progress_bar.max_value = newMax+2
	progress_bar.value = newMax
	trailing_bar.max_value = newMax+2
	trailing_bar.value = newMax
	#associated_entity.health_changed.connect(update_value)
	
	timer.timeout.connect(set_values)
	timer.start()
#makes the values of the bars be equal to the ones of the entity.
func set_values()->void:
	update_max_health()
	if not associated_entity: return
	trailing_bar.value = associated_entity.health
	progress_bar.value = associated_entity.health

	
	
func update_max_health()->void:
	if not associated_entity: return
	#TODO
	pass
func _on_battle_entity_health_changed() -> void:
	if not associated_entity: return
	var value_delta = abs(progress_bar.value - associated_entity.health)
	var tween = get_tree().create_tween()
	tween.tween_property(progress_bar,"value",associated_entity.health, log(value_delta)*0.1).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(trailing_bar,"value",associated_entity.health, log(value_delta)*0.1).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
