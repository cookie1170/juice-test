extends ColorRect

var tween: Tween
var pos: Vector2:
	set(value):
		pos = value
		material.set_shader_parameter("position", pos)


func fade_vignette(dist: float, time: float, type = 1) -> void:
	material.set_shader_parameter("size", size)
	if tween:
		tween.kill()
	tween = get_tree().create_tween().set_ignore_time_scale()
	match type:
		0:
			tween.tween_method(func(value: float):
				material.set_shader_parameter("dist", value),
			material.get_shader_parameter("dist"), get_vignette_max_dist(), time)
		1:
			if material.get_shader_parameter("dist") == dist:
				tween.kill()
				return
			tween.tween_method(func(value: float):
				material.set_shader_parameter("dist", value),
			get_vignette_max_dist(), dist, time)


func get_vignette_max_dist() -> float:
	return size. \
	distance_to(size / 2.0) + \
	material.get_shader_parameter("position"). \
	distance_to(size / 2.0)
