class_name Hitbox
extends Area2D

@export_enum("Enemy", "Player") var type: int
@export var damage: int
@export var detect_hits: bool


func _ready() -> void:
	if not detect_hits:
		set_physics_process(false)
	match type:
		0:
			collision_layer = 2
			collision_mask = 16
		1:
			collision_layer = 4
			collision_mask = 8


func _physics_process(_delta: float) -> void:
	if has_overlapping_areas():
		for area: Hurtbox in get_overlapping_areas():
			if owner.has_method("on_hit"):
				owner.on_hit(area)
