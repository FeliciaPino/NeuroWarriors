extends NeuroAction

const GameManager := preload("res://scripts/game_manager.gd")

var _game_manager:GameManager
var user:BattleEntity

func _init(window: ActionWindow, game_manager:GameManager):
	super(window)
	_game_manager = game_manager
	user = _game_manager.get_entity_by_name("Neuro Sama")
	

func _get_name() -> String:
	return "Neuro action"

func _get_description() -> String:
	return "Makes Neuro do an action on a target.\n Robot Punch: Does medium damage.\n Heart: Heals target.\n Shock: Low damage, removes target AP, halves AP regen for 2 turns."
	
func _get_schema() -> Dictionary:
	return JsonUtils.wrap_schema({
		"action":{
			"enum":_get_available_actions()
		},
		"target": {
			"enum": _get_available_targets()
		}	
	})
	
func _validate_action(data: IncomingData, state: Dictionary) -> ExecutionResult:
	if not user:#this should never ever happen
		return ExecutionResult.failure("Ooops, Neuro has just exploded, try a different character")
		
	var target := data.get_string("target")
	if not target:
		return ExecutionResult.failure(Strings.action_failed_missing_required_parameter.format(["target"]))
	var targets = _get_available_targets()
	if not targets.has(target):
		return ExecutionResult.failure(Strings.action_failed_invalid_parameter.format(["target"]))
	
	state["target"] = _game_manager.get_entity_by_name(target)
	
	var action := data.get_string("action")
	if not action:
		return ExecutionResult.failure(Strings.action_failed_missing_required_parameter.format(["action"]))
	var actions = _get_available_actions()
	if not actions.has(action):
		return ExecutionResult.failure(Strings.action_failed_invalid_parameter.format(["action"]))
	state["action"] = user.get_action_by_name(action)
	if state["action"].price > user.actions_left:
		return ExecutionResult.failure(str("Not enough AP! Need ",state["action"].price,", have ",user.actions_left))
	
	return ExecutionResult.success()
	

func _execute_action(state: Dictionary) -> void:
	print("executing neuro control action")
	_game_manager.do_an_action(user,state["action"],state["target"])

func _get_available_targets():
	if not _game_manager: return #this should never happen, unlesss someone else presses the return to map button mid action
	var result: Array[String] = []
	for f in _game_manager.foes:
		result.append(f.entity_name)
	for p in _game_manager.party:
		result.append(p.entity_name)
	return result
func _get_available_actions():
	if not user: return #this should never happen, unlesss someone else presses the return to map button mid action
	var result: Array[String] = []
	for a in user.actions:
		if a.price <= user.actions_left:result.append(a.action_name) 

	return result
