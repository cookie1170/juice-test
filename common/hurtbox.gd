class_name Hurtbox
extends Area2D

@export_enum("Enemy", "Player") var type: int

func _ready() -> void:
	match type:
		0:
			collision_layer = 8
			collision_mask = 4
		1:
			collision_layer = 16
			collision_mask = 2


func _physics_process(_delta: float) -> void:
	if has_overlapping_areas():
		for area: Hitbox in get_overlapping_areas():
			get_hit(area)


func get_hit(hitbox: Hitbox) -> void:
	if owner.has_method("get_hit"):
		owner.get_hit(hitbox)
