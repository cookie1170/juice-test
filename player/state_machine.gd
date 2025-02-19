class_name StateMachine
extends Node2D


@export var default_state: State
var current_state: State


func _ready() -> void:
	for child: Node in get_children():
		if child is State:
			child.state_changed.connect(change_state)
	current_state = default_state
	change_state(default_state)


func change_state(new_state: State):
	current_state.exit()
	current_state = new_state
	new_state.enter()
	print_debug("changing state to " + new_state.name)
