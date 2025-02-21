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
@export var offset_amount: Vector2 = Vector2(384.0, 0.0)

#endregion

#region nodes

@export_group("Nodes")
@export var hang_timer: Timer
@export var offset_timer: Timer
@export var dash_attack_timer: Timer
@export var mesh: MeshInstance2D
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
var final_offset: Vector2
var is_cam_tweening: bool

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
	move_and_slide()


func apply_gravity(delta_time: float, gravity: float) -> void:
	velocity.y -= gravity * (bounce_peak_y_mult if not hang_timer.is_stopped() else 1.0) * delta_time
	velocity.y = clampf(velocity.y, -INF, terminal_velocity)


func handle_movement(delta_time: float) -> void:
	if state_machine.current_state == dashing_state:
		return
	var move_direction: float = Input.get_axis("left", "right")
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
	if offset_timer.is_stopped() and not velocity.x == 0.0:
		offset_timer.start()
	if velocity.x == 0.0:
		offset_timer.stop()
		final_offset.x = 0.0
	if velocity.y >= 256.0:
		final_offset.y = offset_amount.y
	else:
		final_offset.y = 0.0
	cam_offset_tween.tween_method(phantom_camera.set_follow_offset, \
	phantom_camera.get_follow_offset(), final_offset, offset_time)


func handle_dash_attack() -> void:
	dash_hitbox.monitorable = not dash_attack_timer.is_stopped()
	dash_hitbox.monitoring = not dash_attack_timer.is_stopped()


func get_hit(_hitbox: Hitbox) -> void:
	pass


func on_hit(_hurtbox: Hurtbox) -> void:
	if Input.is_action_pressed("bounce"):
		state_machine.change_state(bouncing_state)
		velocity.y *= 1.25
	print_debug("enemy hit")


func _on_offset_timeout() -> void:
	final_offset.x = signf(velocity.x) * offset_amount.x
