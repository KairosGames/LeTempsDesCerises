extends Node3D

@export var cannon : Node3D
@export var shoot : AkEvent3D

func _on_canon_shoot() -> void:
	shoot.post_event()
	WwiseGlobal.cannon_fire()
	get_parent().move_progress_changed().connect(WwiseGlobal.on_move_progress)
	get_parent().reload_progress_changed().connect(WwiseGlobal.on_reload_progress)
	get_parent().workers_updated().connect(update_cannon_workers)

func _on_canon_start_move() -> void:
	pass # Replace with function body.


func _on_canon_stop_move() -> void:
	pass # Replace with function body.

func update_cannon_workers(workers):
	WwiseGlobal.cannon_workers.clear()
	for agent : Agent in workers:
		for child : Node3D in agent.get_chilren():
			if child.name == "ak_enemy_manager":
				WwiseGlobal.cannon_workers.append(child)
	print(WwiseGlobal.cannon_workers)
