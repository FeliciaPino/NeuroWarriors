extends Label

@onready var entity = $"../Party/GenericGuy"
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if entity.actions.size()>0:
		text = str(entity.actions[0].name,": ",entity.actions[0].description)
