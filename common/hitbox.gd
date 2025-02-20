class_name Hitbox
extends Area2D

@export_enum("Enemy", "Player") var type: int
@export var damage: int


func _ready() -> void:
	collision_mask = 0
	match type:
		0:
			collision_layer = 2
		1:
			collision_layer = 4
