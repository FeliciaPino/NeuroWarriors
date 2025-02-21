extends NeuroAction

var _game_manager:GameManager

func _init(window: ActionWindow, game_manager:GameManager):
	super(window)
	_game_manager = game_manager
	

func _get_name() -> String:
	return "End Turn"

func _get_description() -> String:
	return "Ends your turn"

func _get_schema() -> Dictionary:
	return JsonUtils.wrap_schema({
	})

func _validate_action(data: IncomingData, state: Dictionary) -> ExecutionResult:
	print("validating end turn action")
	return ExecutionResult.success()
func _execute_action(state: Dictionary) -> void:
	print("executing end turn action")
	_game_manager.end_turn()
