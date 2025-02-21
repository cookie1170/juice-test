extends Line2D

@export var mesh: MeshInstance2D
@export_range(0, 512, 1, "or_greater", "suffix:px") var max_dist: float

var pos_tween: Tween


func _process(delta: float) -> void:
	set_point_position(0, mesh.global_position)
	set_point_position(1, mesh.global_position - \
	(mesh.global_position - get_global_mouse_position()). \
	limit_length(max_dist))
