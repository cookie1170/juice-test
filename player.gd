extends CharacterBody2D

#region exports

@export_group("Bouncing")
@export_range(0.0, 512.0, 0.5, "or_greater", "suffix:px") var bounce_height: float = 192.0
@export_range(0.0, 1.0, 0.05, "or_greater", "suffix:s") var peak_time: float = 0.25
@export_range(0.0, 1.0, 0.05, "or_greater", "suffix:s") var fall_time: float = 0.25
@export_range(0.0, 1.0, 0.05, "or_greater", "suffix:s") var hang_time: float = 0.1
@export_range(1.0, 2.0, 0.05, "or_greater") var bounce_peak_x_mult: float = 1.5 
@export_range(0.0, 1.0, 0.05) var bounce_peak_y_mult: float = 0.5
@export_group("Dashing")
@export_range(0.0, 512.0, 0.5, "or_greater", "suffix:px") var dash_distance: float
@export_range(0.0, 1.0, 0.05, "or_greater", "suffix:s") var dash_time: float
@export_group("Rolling")
@export_range(0.0, 512.0, 0.5, "or_greater", "suffix:px/s") var top_speed: float = 320.0
@export_range(0.0, 1.0, 0.05, "or_greater", "suffix:s") var acceleration_time: float = 0.15
@export_range(0.0, 1.0, 0.05, "or_greater", "suffix:s") var deceleration_time: float = 0.15

#endregion

#region nodes

@export_group("Nodes")
@export var hang_timer: Timer

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

var prev_frame_vel: Vector2
var is_dashing: bool = false

#endregion

func _ready() -> void:
	hang_timer.wait_time = hang_time


func _physics_process(delta: float) -> void:
	var collision: bool = move_and_slide()
	apply_gravity(delta)
	handle_movement(delta)
	handle_hang_time()
	handle_dashing()
	if collision:
		if Input.is_action_pressed("bounce"):
			jump()
	prev_frame_vel = velocity


func jump() -> void:
	velocity.y = bounce_vel


func apply_gravity(delta_time: float) -> void:
	if is_on_floor() or is_dashing:
		return
	if velocity.y <= 0:
		velocity.y -= bounce_grav * bounce_peak_y_mult * delta_time
	elif velocity.y > 0:
		velocity.y -= fall_grav * bounce_peak_y_mult * delta_time

func handle_movement(delta_time: float) -> void:
	var move_direction: float = Input.get_axis("left", "right")
	if move_direction:
		velocity.x = move_toward(velocity.x, top_speed * move_direction, acceleration * delta_time)
	else:
		velocity.x = move_toward(velocity.x, 0, deceleration * delta_time)


func handle_hang_time() -> void:
	if prev_frame_vel.y < 0.0 and velocity.y > 0.0:
		hang_timer.start()
		velocity.x *= bounce_peak_x_mult


func handle_dashing() -> void:
	if Input.is_action_just_pressed("dash"):
		dash()


func dash() -> void:
	pass
