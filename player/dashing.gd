extends State

@export var grounded_state: State
@export var falling_state: State

var vel_tween: Tween
var time_tween: Tween
var has_pressed: bool = false

func enter(_previous_state: State = null) -> void:
	super()
	has_pressed = false
	if time_tween:
		time_tween.kill()
	time_tween = get_tree().create_tween()
	time_tween.tween_property(Engine, "time_scale", 0.25, 0.25)


func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("dash") and not has_pressed:
		owner.velocity.y -= owner.fall_grav * delta
	if Input.is_action_just_released("dash"):
		dash()
	if owner.is_on_floor():
		if vel_tween:
			vel_tween.kill()
		if time_tween:
			time_tween.kill()
		Engine.time_scale = 1.0
		state_changed.emit(grounded_state)



func dash() -> void:
	has_pressed = true
	if time_tween:
		time_tween.kill()
	time_tween = get_tree().create_tween()
	time_tween.tween_property(Engine, "time_scale", 1.0, 0.05)
	if vel_tween:
		vel_tween.kill()
	vel_tween = get_tree().create_tween()
	var dash_direction: Vector2 = owner.global_position. \
	direction_to(get_global_mouse_position())
	owner.velocity = owner.dash_vel * dash_direction
	vel_tween.tween_property(owner, "velocity", Vector2.ZERO.lerp(owner.velocity, 0.5), owner.dash_time)
	vel_tween.tween_callback(func():state_changed.emit(
		grounded_state if owner.is_on_floor() else falling_state
	))
