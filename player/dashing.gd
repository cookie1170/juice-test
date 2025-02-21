extends State

@export var grounded_state: State
@export var falling_state: State
@export var dash_indicator: Line2D

var vel_tween: Tween
var time_tween: Tween
var has_pressed: bool = false
var points: PackedVector2Array

func enter(_previous_state: State = null) -> void:
	super()
	dash_indicator.show()
	has_pressed = false
	if time_tween:
		time_tween.kill()
	time_tween = get_tree().create_tween()
	time_tween.tween_property(Engine, "time_scale", 0.25, 0.25)


func exit() -> void:
	super()
	if vel_tween:
		vel_tween.kill()
	if time_tween:
		time_tween.kill()
	dash_indicator.hide()
	Engine.time_scale = 1.0


func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("dash") and not has_pressed:
		owner.velocity.y -= owner.fall_grav * delta
		if Input.is_action_just_pressed("abort_dash"):
			state_changed.emit(falling_state)
	if Input.is_action_just_released("dash"):
		dash()
	if owner.is_on_floor():
		state_changed.emit(grounded_state)



func dash() -> void:
	dash_indicator.hide()
	has_pressed = true
	owner.dash_attack_timer.start()
	owner.hurtbox.i_frame_timer.start(1.0)
	if time_tween:
		time_tween.kill()
	time_tween = get_tree().create_tween()
	time_tween.tween_property(Engine, "time_scale", 1.0, 0.05)
	if vel_tween:
		vel_tween.kill()
	vel_tween = get_tree().create_tween()
	var dash_direction: Vector2 = owner.global_position. \
	direction_to(get_global_mouse_position())
	owner.velocity = owner.dash_vel * dash_direction * get_dash_vel_mult()
	vel_tween.tween_property(owner, "velocity", Vector2.ZERO.lerp(owner.velocity, 0.5), owner.dash_time)
	vel_tween.tween_callback(func(): state_changed.emit(
		grounded_state if owner.is_on_floor() else falling_state
	))


func get_dash_vel_mult() -> float:
	var max_dist: float = dash_indicator.max_dist
	var clamp_dist: float = clampf(owner.mesh.global_position. \
	distance_to(get_global_mouse_position()), 0, max_dist)
	var remapped_dist: float = remap(clamp_dist, 0.0, max_dist, 0.0, 1.0)
	return remapped_dist
