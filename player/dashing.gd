extends State

@export var grounded_state: State
@export var falling_state: State

func enter() -> void:
	super()
	var dash_direction: Vector2 = owner.global_position. \
	direction_to(get_global_mouse_position())
	var tween: Tween = get_tree().create_tween()
	owner.velocity = owner.dash_vel * dash_direction
	tween.tween_property(owner, "velocity", Vector2.ZERO.lerp(owner.velocity, 0.5), owner.dash_time)
	tween.tween_callback(func(): state_changed.emit(
		grounded_state if owner.is_on_floor() else falling_state
	))
