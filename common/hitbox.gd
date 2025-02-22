class_name Hitbox
extends Area2D

@export_enum("Enemy", "Player") var type: int
@export var damage: int
@export var detect_hits: bool


func _ready() -> void:
	match type:
		0:
			collision_layer = 2
		1:
			collision_layer = 4


func on_hit(hurtbox: Hurtbox) -> void:
	if owner.has_method("on_hit"):
		owner.on_hit(hurtbox)
