extends Node3D

@export var cannon : Node3D
@export var shoot : AkEvent3D

func _on_canon_shoot() -> void:
	shoot.post_event()
	WwiseGlobal.cannon_fire()
	get_parent().move_progress_changed().connect(WwiseGlobal.on_move_progress)
	get_parent().reload_progress_changed().connect(WwiseGlobal.on_reload_progress)

func _on_canon_start_move() -> void:
	pass # Replace with function body.


func _on_canon_stop_move() -> void:
	pass # Replace with function body.
