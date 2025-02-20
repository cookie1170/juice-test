extends State

@export var grounded_state: State
@export var bouncing_state: State
@export var hang_timer: Timer

func enter(previous_state: State = null):
	super()
	if previous_state == bouncing_state:
		hang_timer.start()


func _physics_process(delta: float) -> void:
	owner.apply_gravity(delta, owner.fall_grav)
	if owner.is_on_floor():
		state_changed.emit(grounded_state)
