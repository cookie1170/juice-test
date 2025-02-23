extends ColorRect

var shockwave_tween: Tween
var pos: Vector2:
	set(value):
		pos = value
		material.set_shader_parameter("global_position", pos)


func shockwave(force: float, shockwave_size: float,
time: float, thickness: float = 0.0):
	material.set_shader_parameter("screen_size", size)
	if shockwave_tween:
		shockwave_tween.kill()
	shockwave_tween = create_tween().set_ignore_time_scale().set_parallel()
	material.set_shader_parameter("thickness", thickness)
	material.set_shader_parameter("force", force)
	shockwave_tween.tween_method(func(value: float):
		material.set_shader_parameter("force", value), force, 0.0, time)
	shockwave_tween.tween_method(func(value: float):
		material.set_shader_parameter("size", value), 0.0, shockwave_size, time)
