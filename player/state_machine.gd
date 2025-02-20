class_name StateMachine
extends Node2D


@export var default_state: State
var current_state: State


func _ready() -> void:
	for child: Node in get_children():
		if child is State:
			child.state_changed.connect(change_state)
	current_state = default_state
	default_state.enter()


func change_state(new_state: State):
	if new_state == current_state:
		return
	current_state.exit()
	new_state.enter(current_state)
	current_state = new_state
