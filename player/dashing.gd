extends State

@export_group("Variables")
@export var clone_amount: int = 2
@export var vignette_dist: float = 100.0
@export_group("Nodes")
@export var grounded_state: State
@export var falling_state: State
@export var clone_timer: Timer
@export var dash_indicator: Line2D
@export var dash_particles_1: GPUParticles2D
@export var dash_particles_2: GPUParticles2D
@export var clone_scene: PackedScene

var vel_tween: Tween
var time_tween: Tween
var scale_tween: Tween
var color_tween: Tween
var has_pressed: bool = false
var points: PackedVector2Array
var clones_spawned: int


func _ready() -> void:
	super()


func enter(_previous_state: State = null) -> void:
	super()
	dash_indicator.change_visible(true)
	has_pressed = false
	if time_tween:
		time_tween.kill()
	Vignette.fade_vignette(vignette_dist, 0.25, 1)
	time_tween = get_tree().create_tween()
	time_tween.tween_property(Engine, "time_scale", 0.25, 0.25)


func exit() -> void:
	super()
	if vel_tween:
		vel_tween.kill()
	if time_tween:
		time_tween.kill()
	Vignette.fade_vignette(vignette_dist, 0.5, 0)
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


func dash() -> void:
	var dash_direction: Vector2 = owner.global_position. \
	direction_to(get_global_mouse_position())
	owner.velocity = owner.dash_vel * dash_direction * get_dash_vel_mult()
	owner.trail.point_amount = owner.trail.default_point_amount
	dash_particles_2.rotation = dash_direction.angle()
	dash_particles_1.restart()
	dash_particles_2.restart()
	dash_indicator.change_visible(false)
	has_pressed = true
	if scale_tween:
		scale_tween.kill()
	if color_tween:
		color_tween.kill()
	if owner.hit_flash_tween:
		owner.hit_flash_tween.kill()
	scale_tween = get_tree().create_tween()
	scale_tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	color_tween = get_tree().create_tween().set_parallel()
	color_tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	Vignette.fade_vignette(vignette_dist, 0.25, 0)
	owner.mesh.scale.x = 2.0
	owner.mesh.scale.y = 0.5
	owner.mesh.modulate = Color.CRIMSON
	owner.trail.default_color = Color.CRIMSON
	owner.mesh.rotation = owner.velocity.angle()
	color_tween.tween_property(owner.mesh, "modulate", Color.WHITE, 0.5)
	color_tween.tween_property(owner.trail, "default_color", Color.WHITE, 0.5)
	scale_tween.tween_property(owner.mesh, "scale", Vector2(1.0, 1.0), 0.5)
	clones_spawned = 0
	clone_spawn()
	owner.dash_attack_timer.start()
	owner.hurtbox.i_frame_timer.start(1.0)
	if time_tween:
		time_tween.kill()
	time_tween = get_tree().create_tween()
	time_tween.tween_property(Engine, "time_scale", 1.0, 0.05)
	if vel_tween:
		vel_tween.kill()
	vel_tween = get_tree().create_tween()
	vel_tween.tween_property(owner, "velocity", Vector2.ZERO.lerp(owner.velocity, 0.5), owner.dash_time)
	vel_tween.tween_callback(func(): state_changed.emit(
		grounded_state if owner.is_on_floor() else falling_state
	))
	owner.phantom_camera.noise.amplitude = 24.0
	owner.phantom_camera.noise.frequency = 1.0
	owner.phantom_camera.noise.positional_noise = true
	await get_tree().create_timer(0.1).timeout
	owner.phantom_camera.noise.positional_noise = false


func get_dash_vel_mult() -> float:
	var max_dist: float = dash_indicator.max_dist
	var clamp_dist: float = clampf(owner.mesh.global_position. \
	distance_to(get_global_mouse_position()), 0, max_dist)
	var remapped_dist: float = remap(clamp_dist, 0.0, max_dist, 0.5, 1.0)
	return remapped_dist


func clone_spawn() -> void:
	var clone_instance: MeshInstance2D = clone_scene.instantiate()
	owner.call_deferred("add_sibling", clone_instance)
	clone_instance.global_position = owner.mesh.global_position
	clone_instance.modulate = owner.mesh.modulate
	clone_instance.rotation = owner.mesh.rotation
	clone_instance.scale = owner.mesh.scale
	clones_spawned += 1
	if clones_spawned < clone_amount:
		clone_timer.start()
