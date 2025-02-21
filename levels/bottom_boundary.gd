extends Area2D


func _ready() -> void:
	body_entered.connect(_body_entered)


func _body_entered(body: PhysicsBody2D) -> void:
	if body is Player:
		body.state_machine.change_state(body.bouncing_state)
		body.velocity.y = -1600
