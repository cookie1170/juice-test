extends Line2D

@export var mesh: MeshInstance2D
@export_range(0, 512, 1, "or_greater", "suffix:px") var max_dist: float

var mult_tween: Tween
var mult: float


func _process(_delta: float) -> void:
	if not visible:
		return
	set_point_position(0, mesh.global_position)
	set_point_position(1, mesh.global_position - \
		(mesh.global_position - get_global_mouse_position()). \
		limit_length(max_dist) * mult)


func change_visible(value: bool) -> void:
	match value:
		true:
			show()
			if mult_tween:
				mult_tween.kill()
			mult_tween = get_tree().create_tween().set_ignore_time_scale()
			mult = 0.0
			mult_tween.tween_property(self, "mult", 1.0, 0.1)
		false:
			if mult_tween:
				mult_tween.kill()
			mult_tween = get_tree().create_tween().set_ignore_time_scale()
			mult_tween.tween_property(self, "mult", 0.0, 0.1)
			mult_tween.tween_callback(func(): hide())
