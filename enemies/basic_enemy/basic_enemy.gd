class_name BasicEnemy
extends CharacterBody2D

#region nodes

@export_group("Variables")
@export_range(0.0, 4096.0, 1.0, "or_greater", "suffix:px") var notice_range: float = 2048.0
@export_group("Nodes")
@export var update_timer: Timer

#endregion

func _physics_process(_delta: float) -> void:
	pass


func get_hit(_hitbox: Hitbox):
	queue_free()


func _on_update() -> void:
	update_timer.wait_time = randf_range(0.3, 0.7)
