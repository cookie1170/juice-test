class_name Hurtbox
extends Area2D

@export_enum("Enemy", "Player") var type: int

func _ready() -> void:
	collision_layer = 0
	area_entered.connect(_get_hit)
	match type:
		0:
			collision_mask = 4
		1:
			collision_mask = 2


func _get_hit(hitbox: Hitbox) -> void:
	if owner.has_method("get_hit"):
		owner.get_hit(hitbox)
