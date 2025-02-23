extends CanvasLayer

@onready var rect: ColorRect = $ShockwaveRect

var pos: Vector2:
	set(value):
		pos = value
		rect.pos = (rect.size / 2 - pos)
		rect.pos.x = rect.size.x - rect.pos.x
 

func shockwave(force: float, shockwave_size: float,
time: float, thickness: float = 0.0):
	rect.shockwave(force, shockwave_size, time, thickness)
