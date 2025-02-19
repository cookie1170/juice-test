extends State

@export var grounded_state: State

func _physics_process(delta: float) -> void:
	owner.apply_gravity(delta, owner.fall_grav)
	if owner.is_on_floor():
		state_changed.emit(grounded_state)
