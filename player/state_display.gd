extends Label

@export var state_machine: StateMachine
@onready var original_text: String = text

func _physics_process(_delta: float) -> void:
	text = original_text.format([state_machine.current_state.name])
