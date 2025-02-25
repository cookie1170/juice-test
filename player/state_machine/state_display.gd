extends Label

@export var state_machine: StateMachine

func _physics_process(_delta: float) -> void:
	text = state_machine.current_state.name
