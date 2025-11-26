extends Node2D

class_name BattleEntity
@export var challenge_rating:float #How hard an enemy is. (used to calculate xp reward), picked by hand, pretty vibe-based methinks
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
@export var defense:int = 0:
	set(new_value):
		defense = new_value
		defense_changed.emit()
#entity's base attack stat
signal attack_changed
@export var attack:int = 10 
#how many ap is earned at the start of each turn
#TODO: refactor name, it's supposed to be calld ap_regen, not speed. speed doesn't make sense
signal speed_changed
@export var speed:int = 1 

signal received_damage(amount:int, bypass_shield:bool)

var mySpot:Vector2 #where the entity returns after moving and stuff. Y'know, their spot
var is_facing_right:bool = true
signal just_freaking_died_right_now
var alive:bool = true
var actions:Array[BattleAction] = [] #the actions the entity can take, such as active abilites or attacks
var ap:int #how many actions are left in a turn
@export var is_player_controlled:bool
@export var is_stationary:bool

@onready var actions_node = $Actions
@onready var healthBar = %HealthBar
@onready var button:TextureButton = $TextureButton
@onready var action_menu = %ActionMenu
@onready var menu = %Menu
@onready var effects_container = %StatusEffects
@onready var actions_left_label = $Menu/ApDisplay/NinePatchRect/Label
@onready var actions_left_display = $Menu/ApDisplay
@onready var game_manager:GameManager = $"../.."
@onready var visual_node = $visual
@onready var flipper = $visual/Flipper
@onready var animation_player:AnimationPlayer = $AnimationPlayer

@onready var sound_effects = $sound_effects
@onready var sfx_menu_up = $sound_effects/menu_up

var is_menu_opened = false

signal got_clicked_on
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print_debug(str("mouse connections:",get_signal_connection_list("mouse_entered")))
	animation_player.play("idle")
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
	
	mySpot = global_position
	settle_into_spot()
	
	update_menu_actions()
	
	#debug
	if entity_name in CharacterDatabase.ALL_CHARACTERS:
		$"level label".text = str("LEvel:",GameState.characters_save_info[entity_name]["level"],"  xp:",GameState.characters_save_info[entity_name]["experience"])
func face_left():
	is_facing_right = false
	flipper.play("face_left")
func face_right():
	is_facing_right = true
	flipper.play("face_right")
var walking_tween:Tween = null
signal finished_walking
func walk_to(destination:Vector2, speed):
	if destination.x < global_position.x:
		face_left()
	else:
		face_right()
	var distance = global_position.distance_to(destination)
	animation_player.play("walking")
	if walking_tween:
		if walking_tween.is_running():
			walking_tween.kill()
	walking_tween = get_tree().create_tween()
	walking_tween.tween_property(self,"global_position",destination,distance/speed)
	await walking_tween.finished
	finished_walking.emit()


#removes the effect with the given name.
func remove_effect(effectName:String):
	for eff:StatusEffect in effects_container.get_children():
		if eff.effect_name == effectName:
			eff.end_effect()
			eff.queue_free()
func add_effect(effect:StatusEffect):
	print_debug("adding effect "+effect.effect_name)
	#if entity already has this effect, remove it. that way it's replace by the new one
	remove_effect(effect.effect_name)
	effect.set_affected(self)
	effect.start_effect()
	effects_container.add_child(effect)
	
func receive_damage(attack_power:int):
	var damage_taken = max(0,attack_power-defense)
	update_health(health - damage_taken)
	emit_signal("received_damage",attack_power,false)
	#play damaged animation. maybe
	throw_text(str(damage_taken),Color.FIREBRICK)
	make_sound("hit", true)

#makes some info be thrown from the entity. I'm thinking mostly using it to indicate damage
func throw_text(text:String, color:Color = Color.WHITE, size = 2):
	var label = Label.new()
	label.modulate = color
	self.add_child(label)
	label.text = text
	label.z_index = 3
	label.position = Vector2()
	label.scale = Vector2()
	label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 1))
	label.add_theme_constant_override("shadow_offset_x", 2)
	label.add_theme_constant_override("shadow_offset_y", 2)
	var tween = get_tree().create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_parallel()
	tween.tween_property(label,"position:x",20,0.3).set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(label,"position:y",-50,0.3)
	tween.tween_property(label,"scale",Vector2(size,size),0.2)
	tween.chain().tween_property(label, "position:x", 50, 0.6).set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(label,"position:y",50,0.6)
	tween.tween_property(label, "modulate", Color(1,1,1,0), 0.6)
	tween.finished.connect(label.queue_free)
	
func reduce_health(value:int):
	update_health(health - value)
	emit_signal("received_damage",value,true)
	throw_text(str(value))
func update_health(value):
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
	make_sound("bwoaa",true)
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
		effect.affected = self#this shouln't be necessary maybe
		effect.start_of_turn()
		if effect.turns_remaining <= 0:
			remove_effect(effect.effect_name)
	update_health(health)#in case an effect modified health and it didn't regiser correctly
	update_ap_label_text()
	update_menu_actions()

func make_sound(sound_name:String, switch_it_up_a_bit:bool = false):
	var sound_to_play:AudioStreamPlayer
	for sound in sound_effects.get_children():
		if sound.name == sound_name and sound is AudioStreamPlayer:
			sound_to_play = sound
	var original_pitch = sound_to_play.pitch_scale
	if switch_it_up_a_bit:
		sound_to_play.pitch_scale = original_pitch + randf_range(-0.5,0.5)
	sound_to_play.play()
	sound_to_play.finished.connect(func():sound_to_play.pitch_scale = original_pitch)
	
func get_speed():
	return speed
		
func update_ap_label_text():
	actions_left_label.text = str(ap)
	actions_left_display.get_child(0).size.x = len(actions_left_label.text)*9+27

func update_menu_actions():
	#action menu
	for child in action_menu.get_children(): child.queue_free()
	for action in actions:
		var button = Button.new()
		button.text = action.action_name
		button.pressed.connect(func():game_manager.set_selected_action(action))
		button.tooltip_text = "AP:"+str(action.price)+" "+action.description
		if ap < action.price or not is_player_controlled:
			button.disabled = true
		action_menu.add_child(button)
	await get_tree().process_frame
	if is_menu_opened:
		print_debug(str("Entity menu updated while open, giving focus to ",action_menu.get_child(0)))
		action_menu.get_child(0).grab_focus()
func go_to_your_spot()->void:
	walk_to(mySpot,500)
	await finished_walking
	settle_into_spot()
func settle_into_spot():
	#global_position = mySpot
	if animation_player.current_animation == "walking":
		animation_player.play("idle")
	if global_position.x > 550:
		face_left()
	else:
		face_right()

func toggle_menu():
	close_menu() if is_menu_opened else open_menu()
func open_menu():
	if is_menu_opened: return
	print_debug(str(self,": opening menu"))
	update_ap_label_text()
	
	is_menu_opened = true
	if is_player_controlled:
		sfx_menu_up.play()
	var tween = get_tree().create_tween().set_parallel()
	tween.tween_property(menu, "modulate", Color(1,1,1,1) , 0.02)
	tween.tween_property(menu, "scale", Vector2(1,1), 0.2)
	if action_menu.get_child_count()>0:
		action_menu.get_child(0).grab_focus()
	
	
func close_menu():
	if not is_menu_opened: return
	print_debug(str(self,": closing menu"))
	is_menu_opened = false
	var tween = get_tree().create_tween().set_parallel()
	tween.tween_property(menu, "modulate", Color(1,1,1,0) , 0.2)
	tween.tween_property(menu, "scale", Vector2(), 0.2)

#returns a dictionoray like this ["action":BattleAction,"target",BattleEntity]
func figure_out_something_to_do():
	var posible_actions = get_posible_actions()
	if not are_there_posible_action(): return {"action":null,"target":null}
	var chosen_action:BattleAction = posible_actions.pick_random()
	#5% chance to end turn
	if randi()%100<=5 or chosen_action==null: return {"action":null,"target":null}
	var posible_targets = game_manager.party if is_player_controlled == chosen_action.isPositive else game_manager.foes
	if posible_targets.size() <= 0: return {"action":null,"target":null}
	var chosen_target:BattleEntity = posible_targets.pick_random()
	return {"action":chosen_action, "target":chosen_target}

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
	print_debug(entity_name+": Hey! " + other.entity_name + " got all up in my personal space!")
	pass

func _on_texture_button_button_down() -> void:
	game_manager.battleEntityClicked(self)
	got_clicked_on.emit()

func _on_texture_button_mouse_entered() -> void:
	button.grab_focus()


func _on_texture_button_focus_entered() -> void:
	game_manager.battle_entity_grabbed_focus(self)
