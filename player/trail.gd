extends Line2D

@export var default_point_amount: int
@export var dash_attack_timer: Timer

var point_amount: int

func _timeout() -> void:
	if point_amount > points.size():
		add_point(owner.global_position - Vector2(0.0, 24.0))
	elif points.size() > 0:
		remove_point(0)
