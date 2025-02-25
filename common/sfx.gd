extends AudioStreamPlayer2D
class_name FancySFX

@export var sounds: Array[AudioStream]

func play_sfx(pitch_min: float = 0.8, pitch_max: float = 1.2) -> void:
	pitch_scale = randf_range(pitch_min, pitch_max)
	stream = sounds.pick_random()
	play()
