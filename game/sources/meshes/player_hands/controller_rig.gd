@tool
class_name Arms extends Node3D

@export var progress: int = 0
@export var in_progress: bool = false

func set_progress_step(new_step: int) -> void:
	progress = new_step

func set_in_progress(is_in_progress: bool) -> void:
	in_progress = is_in_progress
