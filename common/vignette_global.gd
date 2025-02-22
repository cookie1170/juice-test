extends CanvasLayer

@onready var rect: ColorRect = $Vignette

var pos: Vector2:
	set(value):
		pos = value
		rect.pos = pos


func fade_vignette(dist: float, time: float, type = 1) -> void:
	rect.fade_vignette(dist, time, type)
