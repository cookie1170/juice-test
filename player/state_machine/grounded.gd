extends State

@export var falling_state: State
@export var bouncing_state: State

var point_amt_tween: Tween


func enter(_previous_state: State = null) -> void:
	super()
	if point_amt_tween:
		point_amt_tween.kill()
	point_amt_tween = get_tree().create_tween()
	point_amt_tween.tween_property(owner.trail, "point_amount", 0, 0.25)
	if not owner.landing_sfx.playing:
		owner.landing_sfx.play_sfx(1.2, 1.6)


func _physics_process(_delta: float) -> void:
	if not owner.is_on_floor():
		state_changed.emit(falling_state)
	if Input.is_action_pressed("bounce"):
		state_changed.emit(bouncing_state)
