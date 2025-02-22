extends State

@export var grounded_state: State
@export var falling_state: State
@export var dash_indicator: Line2D
@export var dash_particles_1: GPUParticles2D
@export var dash_particles_2: GPUParticles2D

var vel_tween: Tween
var time_tween: Tween
var scale_tween: Tween
var color_tween: Tween
var has_pressed: bool = false
var points: PackedVector2Array

func enter(_previous_state: State = null) -> void:
	super()
	dash_indicator.change_visible(true)
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
	if scale_tween:
		scale_tween.kill()
	if color_tween:
		color_tween.kill()
	owner.mesh.modulate = Color.WHITE
	owner.trail.default_color = Color.WHITE
	owner.mesh.scale = Vector2(1.0, 1.0)
	dash_particles_1.emitting = false
	dash_particles_2.emitting = false
	dash_indicator.change_visible(false)
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
	if has_pressed:
		owner.mesh.rotation = owner.velocity.angle()



func dash() -> void:
	var dash_direction: Vector2 = owner.global_position. \
	direction_to(get_global_mouse_position())
	dash_particles_2.rotation = dash_direction.angle()
	dash_particles_1.restart()
	dash_particles_2.restart()
	dash_indicator.change_visible(false)
	has_pressed = true
	if scale_tween:
		scale_tween.kill()
	if color_tween:
		color_tween.kill()
	scale_tween = get_tree().create_tween()
	color_tween = get_tree().create_tween().set_parallel()
	owner.mesh.scale.x = 2.0
	owner.mesh.scale.y = 0.5
	owner.mesh.modulate = Color.CRIMSON
	owner.trail.default_color = Color.CRIMSON
	color_tween.tween_property(owner.mesh, "modulate", Color.WHITE, 0.5)
	color_tween.tween_property(owner.trail, "default_color", Color.WHITE, 0.5)
	scale_tween.tween_property(owner.mesh, "scale", Vector2(1.0, 1.0), 0.25)
	owner.dash_attack_timer.start()
	owner.hurtbox.i_frame_timer.start(1.0)
	if time_tween:
		time_tween.kill()
	time_tween = get_tree().create_tween()
	time_tween.tween_property(Engine, "time_scale", 1.0, 0.05)
	if vel_tween:
		vel_tween.kill()
	vel_tween = get_tree().create_tween()
	owner.velocity = owner.dash_vel * dash_direction * get_dash_vel_mult()
	vel_tween.tween_property(owner, "velocity", Vector2.ZERO.lerp(owner.velocity, 0.5), owner.dash_time)
	vel_tween.tween_callback(func(): state_changed.emit(
		grounded_state if owner.is_on_floor() else falling_state
	))


func get_dash_vel_mult() -> float:
	var max_dist: float = dash_indicator.max_dist
	var clamp_dist: float = clampf(owner.mesh.global_position. \
	distance_to(get_global_mouse_position()), 0, max_dist)
	var remapped_dist: float = remap(clamp_dist, 0.0, max_dist, 0.5, 1.0)
	return remapped_dist
