extends Node2D

class_name BattleEntity
#stats. they are set in the inspector, so these default values shouldn't ever do anything
signal health_changed
@export var health:int = 100:
	set(new_value):
		health = new_value
		health_changed.emit()
signal maxHealth_changed
@export var maxHealth:int = 100
@export var entity_name:String = "default name"
@export var entity_description:String = "default description"
signal defense_changed
@export var defense:int = 2:
	set(new_value):
		defense = new_value
		defense_changed.emit()
#entity's base attack stat
signal attack_changed
@export var attack:int = 10 
#how many ap is earned at the start of each turn
signal speed_changed
@export var speed:int = 1 

signal received_damage(amount:int, bypass_shield:bool)

var mySpot:Vector2 #where the entity returns after moving and stuff. Y'know, their spot
signal just_freaking_died_right_now
var alive:bool = true
var actions:Array[BattleAction] = [] #the actions the entity can take, such as active abilites or attacks
var ap:int #how many actions are left in a turn
@export var is_player_controlled:bool

@onready var actions_node = $Actions
@onready var healthBar = $HealthBar
@onready var selection_circle = $SelectionCircle
@onready var action_menu = $Menu/ActionMenu
@onready var menu = $Menu
@onready var effects_container = $HealthBar/StatusEffects
@onready var actions_left_label = $Menu/ApDisplay/NinePatchRect/Label
@onready var actions_left_display = $Menu/ApDisplay
@onready var info_panel = $Menu/info_container/Info
@onready var game_manager = $"../.." #TODO: update this
@onready var animated_sprite:AnimatedSprite2D = $AnimatedSprite2D
@onready var animation_player = $BattleEntityAnimationPlayer
@onready var explosion_animated_sprite = $explosion

@onready var sound_effects = $sound_effects
@onready var sfx_menu_up = $sound_effects/menu_up

var is_selected:bool = false
var is_hovered_over_with_the_mouse = false
var is_menu_opened = false

signal got_clicked_on
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print(get_signal_connection_list("mouse_entered"))

	print(entity_name+" is ready")
	animated_sprite.play("default")
	explosion_animated_sprite.visible = false
	is_hovered_over_with_the_mouse = false
	for child in actions_node.get_children():
		if child is BattleAction:
			actions.append(child)
	#this loop shouldn't be necessary. It's mostly for debugging
	for child in get_children():
		if child is BattleAction:
			actions.append(child)
			
	alive = true
	ap = 0
	#menu
	menu.modulate.a = 0
	menu.scale = Vector2()
	#menu.rotation = 3.1416
	#health
	if health > maxHealth: health = maxHealth
	
	#healthBar.max_value = maxHealth +1 #I add one to the max because otherwise the tippy top of the value will be the part on the border, you know those 2 pixels? Yeah
	#healthBar.min_value = -1 #Same as with the max, one less than 0 so it doesn't look empty when the value is 1
	healthBar.setup(maxHealth,defense)
	
	selection_circle.visible = false
	if not is_player_controlled: selection_circle.modulate = Color.RED
	selection_circle.modulate.a = 0.5
	
	mySpot = global_position#I'll probably change this later
	settle_into_spot()
	
	update_menu_actions()
	update_info_panel()
	
	
#removes the effect with the given name.
func remove_effect(effectName:String):
	for eff in effects_container.get_children():
		if eff.effect_name == effectName:
			eff.end_effect()
			eff.queue_free()
func add_effect(effect:StatusEffect):
	print("adding effect "+effect.effect_name)
	#if entity already has this effect, remove it. that way it's replace by the new one
	remove_effect(effect.effect_name)
	effect.set_affected(self)
	effect.start_effect()
	effects_container.add_child(effect)
	
func receive_damage(attack_power):
	var damage_taken = max(0,attack_power-defense)
	update_health(health - damage_taken)
	emit_signal("received_damage",attack_power,false)
	#play damaged animation. maybe
	throw_text(str(damage_taken),Color.FIREBRICK)

#makes some info be thrown from the entity. I'm thinking mostly using it to indicate damage
func throw_text(text:String, color:Color = Color.WHITE):
	var label = Label.new()
	label.modulate = color
	self.add_child(label)
	label.text = text
	label.position = Vector2()
	label.scale = Vector2()
	var tween = get_tree().create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_parallel()
	tween.tween_property(label,"position:x",20,0.3).set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(label,"position:y",-50,0.3)
	tween.tween_property(label,"scale",Vector2(1,1),0.2)
	tween.chain().tween_property(label, "position:x", 50, 0.6).set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(label,"position:y",50,0.6)
	tween.tween_property(label, "modulate", Color(1,1,1,0), 0.6)
	tween.finished.connect(label.queue_free)
	
func reduce_health(value:int):
	update_health(health - value)
	emit_signal("received_damage",value,true)
	throw_text(str(value))
func update_health(value):
	update_info_panel()
	health = value
	if health>maxHealth: health=maxHealth
	health_changed.emit()
	alive = health>0
	if not alive:
		just_freaking_died_right_now.emit()
		animation_player.play("die")
func update_ap(value:int):
	ap = value
	update_ap_label_text()
	update_menu_actions()
	
func heal(amount:int):
	throw_text(str(amount),Color.GREEN)
	update_health(health+amount)
	
func did_an_action(price:int):
	ap -= price
	update_ap_label_text()
	update_menu_actions()
	#making sure this isn't negative will be handled... somewhere else idk
func set_up_at_start_of_turn():
	ap += get_speed()
	for effect in effects_container.get_children():
		if not effect is StatusEffect: continue
		effect.start_of_turn()
		if effect.turns_remaining <= 0:
			remove_effect(effect.effect_name)
	update_health(health)#in case an effect modified health and it didn't regiser correctly
	update_ap_label_text()
	update_menu_actions()

func make_sound(sound_name:String):
	for sound in sound_effects.get_children():
		if sound.name == sound_name:
			sound.play()
func get_speed():
	return speed
		
func update_ap_label_text():
	actions_left_label.text = str(ap)
	actions_left_display.get_child(0).size.x = len(actions_left_label.text)*9+27

func update_info_panel() -> void:
	var info_panel_info = [entity_name,str("Max Health: ",maxHealth),str("Health: ",health),str("Attack: ",attack),str("Defense: ",defense),str("AP regen: ",speed)]
	for i in range(info_panel.get_child_count()):
		info_panel.get_child(i).text = info_panel_info[i]
func update_menu_actions():
	if not is_player_controlled:
		return
	#action menu
	for child in action_menu.get_children(): child.queue_free()
	for action in actions:
		var button = Button.new()
		button.text = action.action_name
		button.pressed.connect(func():game_manager.set_selected_action(action))
		button.tooltip_text = "AP:"+str(action.price)+" "+action.description
		if ap < action.price:
			button.disabled = true
		action_menu.add_child(button)

func go_to_your_spot()->void:
	var distance_to_spot = mySpot.distance_to(global_position)
	if distance_to_spot < 1: return
	var tween = get_tree().create_tween()
	animated_sprite.play("run")
	#maybe make the time depend on how far away they are from their spot?
	tween.tween_property(self,"global_position",mySpot, 1)
	tween.finished.connect(settle_into_spot)
func settle_into_spot():
	global_position = mySpot
	animated_sprite.play("default")
	animated_sprite.flip_h = global_position.x > 550
	

func toggle_menu():
	close_menu() if is_menu_opened else open_menu()
func open_menu():
	update_ap_label_text()
	update_info_panel()
	
	is_menu_opened = true
	if is_player_controlled:
		sfx_menu_up.play()
	var tween = get_tree().create_tween().set_parallel()
	tween.tween_property(menu, "modulate", Color(1,1,1,1) , 0.02)
	tween.tween_property(menu, "scale", Vector2(1,1), 0.2)
	#tween.tween_property(menu,"rotation",0,0.25)
	
func close_menu():
	is_menu_opened = false
	var tween = get_tree().create_tween().set_parallel()
	tween.tween_property(menu, "modulate", Color(1,1,1,0) , 0.2)
	tween.tween_property(menu, "scale", Vector2(), 0.2)
	#tween.tween_property(menu,"rotation",3.14159,0.25)

#returns whether or not it's possible to do anything with the AP left
func are_there_posible_action():
	var ans = false
	for act in actions: if act.price <= ap: ans = true
	return ans
func get_action_by_name(action_name:String)->BattleAction:
	for a in actions:
		if a.action_name == action_name:
			return a
	return null
#creates and returns an array with all actions that can be (individually) perfomred with the AP left
func get_posible_actions():
	var ans = []
	for act in actions: if act.price <= ap:  ans.append(act)
	return ans
func get_strongest_posible_action():
	var pa = get_posible_actions()
	var ans = pa[0]
	var m = ans.price
	for act in pa: if act.price > m:  ans = act
	return ans
func got_on_your_personal_space(other:BattleEntity):
	print(entity_name+": Hey! " + other.entity_name + " got all up in my personal space!")
	pass

func _on_area_2d_mouse_entered() -> void:
	is_hovered_over_with_the_mouse = true
	selection_circle.visible = true
	

func _on_area_2d_mouse_exited() -> void:
	is_hovered_over_with_the_mouse = false
	selection_circle.visible = false

func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		is_selected = true
		game_manager.battleEntityClicked(self)
		got_clicked_on.emit()
