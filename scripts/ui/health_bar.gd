extends TextureProgressBar
@onready var trailing_bar = $TextureProgressBar
@onready var timer = $Timer
@onready var shield_bar = $Shield_bar
@onready var associated_entity:BattleEntity = $".."
func setup(newMax:int, defense:int)->void:
	max_value = newMax+1
	value = newMax
	min_value = -2 #Same as with the max, one less than 0 so it doesn't look empty when the value is 1
	size.x = max_value/2 + 11
	position.x = -size.x/2
	trailing_bar.size = size
	trailing_bar.position=Vector2()
	trailing_bar.max_value = max_value
	trailing_bar.value = value
	trailing_bar.min_value = min_value
	#associated_entity.health_changed.connect(update_value)
	
	shield_bar.size.x = defense/2
	shield_bar.position.x = size.x
	shield_bar.max_value = defense
	shield_bar.value = defense
	associated_entity.defense_changed.connect(update_defense)
	timer.timeout.connect(set_values)
	timer.start()
#makes the values of the bars be equal to the ones of the entity.
func set_values()->void:
	update_defense()
	update_max_health()
	if not associated_entity: return
	trailing_bar.value = associated_entity.health
	self.value = associated_entity.health

	
func update_defense()->void:
	if not associated_entity: return
	var new_defense:int = associated_entity.defense
	shield_bar.visible = new_defense>0
	shield_bar.max_value = new_defense
	shield_bar.value = new_defense
	shield_bar.size.x = new_defense/2+5
	
func update_max_health()->void:
	if not associated_entity: return
	#TODO
	pass
func _on_battle_entity_health_changed() -> void:
	if not associated_entity: return
	if associated_entity.health > value:
		var tween = get_tree().create_tween().set_parallel()
		tween.tween_property(trailing_bar,"value",associated_entity.health,0.2)
		tween.finished.connect(func():self.value = trailing_bar.value)


func _on_battle_entity_received_damage(amount: int, bypass_shield: bool) -> void:
	if not associated_entity: return
	if amount<=0: return
	var ani_time:float = 0.3
	var trail_speed:float = 100
	var tween:Tween = get_tree().create_tween()
	var deltaH:int = abs(trailing_bar.value - associated_entity.health)
	var deltaD:int = min(amount,associated_entity.defense)
	var delta:int = deltaH+deltaD
	
	if not bypass_shield:
		
		tween.tween_property(shield_bar, "value", max(0, shield_bar.max_value-amount), ani_time*deltaD/delta)
		tween.tween_property(trailing_bar,"value",associated_entity.health,ani_time*deltaH/delta)
		tween.parallel().tween_property(self,"value",associated_entity.health,float(deltaH)/trail_speed+0.1)
	else:
		tween.tween_property(trailing_bar,"value",associated_entity.health,ani_time)
		tween.parallel().tween_property(self,"value",associated_entity.health,float(deltaH)/trail_speed+0.1)
	tween.finished.connect(timer.start)
