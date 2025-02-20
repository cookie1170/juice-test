class_name State
extends Node2D

@warning_ignore("unused_signal")
signal state_changed(new_state: State)


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_DISABLED


func enter(_previous_state: State = null) -> void:
	process_mode = Node.PROCESS_MODE_INHERIT


func exit() -> void:
	process_mode = Node.PROCESS_MODE_DISABLED
