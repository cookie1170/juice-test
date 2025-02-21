class_name Player
extends CharacterBody2D

#region exports

@export_group("Bouncing")
@export_range(0.0, 512.0, 0.5, "or_greater", "suffix:px") var bounce_height: float = 192.0
@export_range(0.0, 1.0, 0.05, "or_greater", "suffix:s") var peak_time: float = 0.25
@export_range(0.0, 1.0, 0.05, "or_greater", "suffix:s") var fall_time: float = 0.25
@export_range(0.0, 1.0, 0.05, "or_greater", "suffix:s") var hang_time: float = 0.1
@export_range(0.0, 1.0, 0.05) var bounce_peak_y_mult: float = 0.5
@export_group("Dashing")
@export_range(0.0, 512.0, 0.5, "or_greater", "suffix:px") var dash_distance: float
@export_range(0.0, 1.0, 0.05, "or_greater", "suffix:s") var dash_time: float
@export_group("Rolling")
@export_range(0.0, 512.0, 0.5, "or_greater", "suffix:px/s") var top_speed: float = 320.0
@export_range(0.0, 1.0, 0.05, "or_greater", "suffix:s") var acceleration_time: float = 0.15
@export_range(0.0, 1.0, 0.05, "or_greater", "suffix:s") var deceleration_time: float = 0.15
@export_range(0.0, 1.0, 0.05) var air_accel_mult: float = 0.5
@export_range(0.0, 1.0, 0.05) var air_decel_mult: float = 0.5

#endregion

#region nodes

@export_group("Nodes")
@export var hang_timer: Timer
@export var mesh: MeshInstance2D
@export var state_machine: StateMachine
@export var bouncing_state: State
@export var falling_state: State
@export var dashing_state: State
@export var grounded_state: State

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

#endregion


func _ready() -> void:
	hang_timer.wait_time = hang_time
	Ref.player = self


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("dash"):
		if state_machine.current_state == grounded_state:
			state_machine.change_state(bouncing_state)
		state_machine.change_state(dashing_state)


func _physics_process(delta: float) -> void:
	handle_movement(delta)
	move_and_slide()


func apply_gravity(delta_time: float, gravity: float) -> void:
	velocity.y -= gravity * (bounce_peak_y_mult if not hang_timer.is_stopped() else 1.0) * delta_time

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


func get_hit(_hitbox: Hitbox) -> void:
	pass


func on_hit(_hurtbox: Hurtbox) -> void:
	if Input.is_action_pressed("bounce"):
		state_machine.change_state(bouncing_state)
		velocity.y *= 1.25
	print_debug("enemy hit")
