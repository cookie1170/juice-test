class_name Hurtbox
extends Area2D

@export_enum("Enemy", "Player") var type: int
@export_range(0.0, 1.0, 0.05, "or_greater", "suffix:s") var total_i_frames: float = 0.1

@onready var i_frame_timer: Timer = Timer.new()

func _ready() -> void:
	add_child(i_frame_timer)
	i_frame_timer.one_shot = true
	i_frame_timer.wait_time = total_i_frames
	match type:
		0:
			collision_layer = 8
			collision_mask = 4
		1:
			collision_layer = 16
			collision_mask = 2


func _physics_process(_delta: float) -> void:
	if not i_frame_timer.is_stopped():
		return
	if has_overlapping_areas():
		for area: Hitbox in get_overlapping_areas():
			i_frame_timer.start()
			get_hit(area)


func get_hit(hitbox: Hitbox) -> void:
	if owner.has_method("get_hit"):
		owner.get_hit(hitbox)
