extends State

@export var falling_state: State
@export var grounded_state: State

func enter(_previous_state: State = null) -> void:
	super()
	owner.velocity.y = owner.bounce_vel


func _physics_process(delta: float) -> void:
	owner.apply_gravity(delta, owner.fall_grav)
	if owner.velocity.y > 0:
		state_changed.emit(falling_state)
	if owner.is_on_floor():
		state_changed.emit(grounded_state)
