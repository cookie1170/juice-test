extends Node


func hitstop(time: float = 0.1) -> void:
	var original_timescale: float = Engine.time_scale
	Engine.time_scale = 0.0
	await get_tree().create_timer(time, true, false, true).timeout
	Engine.time_scale = original_timescale
