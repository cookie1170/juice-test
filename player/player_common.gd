class_name Player
extends CharacterBody2D

#region exports

@export_group("Bouncing")
@export_range(0.0, 512.0, 0.5, "or_greater", "suffix:px") var bounce_height: float = 192.0
@export_range(0.0, 1.0, 0.05, "or_greater", "suffix:s") var peak_time: float = 0.25
@export_range(0.0, 1.0, 0.05, "or_greater", "suffix:s") var fall_time: float = 0.25
@export_range(0.0, 1.0, 0.05, "or_greater", "suffix:s") var hang_time: float = 0.1
@export_range(0.0, 1.0, 0.05) var bounce_peak_y_mult: float = 0.5
@export_range(0.0, 4096, 0.5, "or_greater", "suffix:px/s") var terminal_velocity: float
@export_group("Dashing")
@export_range(0.0, 1024.0, 0.5, "or_greater", "suffix:px") var dash_distance: float
@export_range(0.0, 1.0, 0.05, "or_greater", "suffix:s") var dash_time: float
@export_group("Rolling")
@export_range(0.0, 1024.0, 0.5, "or_greater", "suffix:px/s") var top_speed: float = 320.0
@export_range(0.0, 1.0, 0.05, "or_greater", "suffix:s") var acceleration_time: float = 0.15
@export_range(0.0, 1.0, 0.05, "or_greater", "suffix:s") var deceleration_time: float = 0.15
@export_range(0.0, 1.0, 0.05) var air_accel_mult: float = 0.5
@export_range(0.0, 1.0, 0.05) var air_decel_mult: float = 0.5
@export_group("Camera Settings")
@export_range(0.0, 1.0, 0.05, "or_greater", "suffix:s") var offset_time: float = 0.25
@export_range(0.0, 1.5, 0.05, "or_greater") var zoom_amount_on_hit: float = 1.1
@export var offset_amount: Vector2 = Vector2(384.0, 0.0)

#endregion

#region nodes

@export_group("Nodes")
@export var hang_timer: Timer
@export var offset_timer: Timer
@export var dash_attack_timer: Timer
@export var mesh: MeshInstance2D
@export var dash_particles: GPUParticles2D
@export var hurt_particles_1: GPUParticles2D
@export var hurt_particles_2: GPUParticles2D
@export var wavedash_particle: GPUParticles2D
@export var trail: Line2D
@export var bg_highlight: TileMapLayer
@export var dash_hitbox: Hitbox
@export var hurtbox: Hurtbox
@export var state_machine: StateMachine
@export var bouncing_state: State
@export var falling_state: State
@export var dashing_state: State
@export var grounded_state: State
@export var phantom_camera: PhantomCamera2D

#endregion

#region calculations

@onready var bounce_vel: float = -(2.0 * bounce_height) / peak_time
@onready var bounce_grav: float = (-2.0 * bounce_height) / (peak_time ** 2)
@onready var fall_grav: float = (-2.0 * bounce_height) / (fall_time ** 2)
@onready var acceleration: float = top_speed / acceleration_time
@onready var deceleration: float = top_speed / deceleration_time
@onready var dash_vel: float = dash_distance / dash_time

#endregion

#region misc variables

var is_dashing: bool = false
var cam_offset_tween: Tween
var hit_flash_tween: Tween
var zoom_tween: Tween
var final_offset: Vector2
var is_cam_tweening: bool
var move_direction: float

#endregion

func _ready() -> void:
	Ref.player = self
	hang_timer.wait_time = hang_time


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("dash"):
		if state_machine.current_state == grounded_state:
			state_machine.change_state(bouncing_state)
		state_machine.change_state(dashing_state)


func _physics_process(delta: float) -> void:
	handle_movement(delta)
	handle_cam_offset()
	handle_dash_attack()
	handle_mesh_rotation()
	move_and_slide()

#region handlers

func apply_gravity(delta_time: float, gravity: float) -> void:
	velocity.y -= gravity * (bounce_peak_y_mult if not hang_timer.is_stopped()
	else 1.0) * delta_time
	velocity.y = clampf(velocity.y, -INF, terminal_velocity)


func handle_movement(delta_time: float) -> void:
	Vignette.pos = phantom_camera.to_local(mesh.global_position)
	if state_machine.current_state == dashing_state:
		move_direction = signf(velocity.x)
		return
	move_direction = Input.get_axis("left", "right")
	if move_direction:
		velocity.x = move_toward(
				velocity.x, top_speed * move_direction,
				acceleration * delta_time * (air_accel_mult if
				not state_machine.current_state == grounded_state
				else 1.0)
		)
	else:
		velocity.x = move_toward(
				velocity.x, 0.0,
				deceleration * delta_time * (air_decel_mult if
				not state_machine.current_state == grounded_state
				else 1.0)
		)


func handle_cam_offset() -> void:
	if cam_offset_tween:
		cam_offset_tween.kill()
	cam_offset_tween = get_tree().create_tween()
	if (not velocity.x == 0.0 and not
	final_offset.x == move_direction * offset_amount.x):
		if offset_timer.is_stopped(): 
			offset_timer.start()
	else:
		offset_timer.stop()
	if velocity.x == 0.0:
		offset_timer.stop()
		final_offset.x = 0.0
	if velocity.y >= 256.0:
		final_offset.y = offset_amount.y
	else:
		final_offset.y = 0.0
	cam_offset_tween.tween_method(phantom_camera.set_follow_offset,
	phantom_camera.get_follow_offset(), final_offset, offset_time)


func handle_dash_attack() -> void:
	if state_machine.current_state == grounded_state:
		dash_attack_timer.stop()
	if velocity.length_squared() < 262144.0: # 512 squared
		dash_attack_timer.stop()
	dash_particles.emitting = not dash_attack_timer.is_stopped()
	dash_hitbox.monitorable = not dash_attack_timer.is_stopped()
	dash_hitbox.monitoring = not dash_attack_timer.is_stopped()

func handle_mesh_rotation() -> void:
	mesh.rotation = velocity.angle()

#endregion


func get_hit(hitbox: Hitbox) -> void:
	var hit_direction: Vector2 = -global_position. \
	direction_to(hitbox.global_position)
	hit_direction.y = clampf(hit_direction.y, -1, -0.2)
	var hit_angle: float = hit_direction.angle()
	velocity = hit_direction * 1024
	state_machine.change_state(bouncing_state)
	if hit_flash_tween:
		hit_flash_tween.kill()
	if dashing_state.color_tween:
		dashing_state.color_tween.kill()
	Vignette.fade_vignette(128.0, 0.1, 1)
	Hitstop.hitstop(0.2)
	await get_tree().create_timer(0.2, true, false, true).timeout
	var time_tween: Tween = get_tree().create_tween().set_ignore_time_scale()
	hit_flash_tween = get_tree().create_tween().set_ignore_time_scale()
	hit_flash_tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	hit_flash_tween.set_parallel()
	hit_flash_tween.tween_property(bg_highlight, "modulate",
	Color.CRIMSON, 0.05)
	hit_flash_tween.tween_property(mesh, "modulate", Color.CRIMSON, 0.05)
	hit_flash_tween.tween_property(bg_highlight, "modulate",
	Color.html("82f9ffff"), 0.5).set_delay(0.15)
	hit_flash_tween.tween_property(mesh, "modulate",
	Color.WHITE, 0.5).set_delay(0.15)
	time_tween.tween_property(Engine, "time_scale", 0.1, 0.1)
	time_tween.tween_property(Engine, "time_scale", 1.0, 0.75)
	hurt_particles_1.rotation = hit_angle
	hurt_particles_2.rotation = hit_angle
	shake(96.0, 3.0, 0.35)
	zoom_tween = get_tree().create_tween().set_ignore_time_scale()
	zoom_tween.tween_method(func(value: float):
		phantom_camera.set_zoom(Vector2(value, value)),
		0.75, zoom_amount_on_hit, 0.1)
	zoom_tween.tween_method(func(value: float):
		phantom_camera.set_zoom(Vector2(value, value)),
		zoom_amount_on_hit, 0.75, 0.2)
	await get_tree().create_timer(0.15, true, false, true).timeout
	hurt_particles_1.restart()
	hurt_particles_2.restart()
	await get_tree().create_timer(0.2, true, false, true).timeout
	Vignette.fade_vignette(128.0, 0.35, 0)


func on_hit(_hurtbox: Hurtbox) -> void:
	if Input.is_action_pressed("bounce"):
		if (state_machine.current_state == dashing_state
		and abs(velocity.x) > 512.0):
			shake(48.0, 2.0, 0.25)
			wavedash_particle.restart()
		state_machine.change_state(bouncing_state)
		velocity.y *= 1.25
	shake(24.0, 1.5, 0.1)
	Hitstop.hitstop()


func _on_offset_timeout() -> void:
	final_offset.x = move_direction * offset_amount.x


func shake(ampl: float, freq: float, time: float) -> void:
	phantom_camera.noise.amplitude = ampl
	phantom_camera.noise.frequency = freq
	phantom_camera.noise.positional_noise = true
	await get_tree().create_timer(time, true, false, true).timeout
	phantom_camera.noise.positional_noise = false
