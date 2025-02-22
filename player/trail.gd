extends Line2D

@export var point_amount: int

func _timeout() -> void:
	add_point(owner.global_position - Vector2(0.0, 24.0))
	if points.size() > point_amount:
		remove_point(0)
