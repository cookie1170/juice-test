extends State

@export var falling_state: State
@export var bouncing_state: State

func _physics_process(_delta: float) -> void:
	if not owner.is_on_floor():
		state_changed.emit(falling_state)
	if Input.is_action_pressed("bounce"):
		state_changed.emit(bouncing_state)
