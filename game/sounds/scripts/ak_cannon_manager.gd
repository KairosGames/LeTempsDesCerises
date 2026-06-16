class_name AkCannon extends Node3D

@onready var shoot : AkEvent3D = $Cannon_Shoot
@onready var cannon: Canon = $".."

func _ready() -> void:
	cannon.move_progress_changed.connect(WwiseGlobal.on_move_progress)
	cannon.reload_progress_changed.connect(WwiseGlobal.on_reload_progress)
	cannon.workers_updated.connect(update_cannon_workers)
	cannon.shoot.connect(_on_canon_shoot)
	cannon.start_move.connect(_on_canon_start_move)
	cannon.stop_move.connect(_on_canon_stop_move)

func _on_canon_shoot() -> void:
	shoot.post_event()
	WwiseGlobal.cannon_fire()

func _on_canon_start_move() -> void:
	pass # Replace with function body.


func _on_canon_stop_move() -> void:
	pass # Replace with function body.

func update_cannon_workers(workers: Array[Agent]) -> void:
	WwiseGlobal.cannon_workers.clear()
	for agent: Agent in workers:
		var ak_enemy: Node = agent.get_node_or_null(^"ak_enemy_manager")
		if not ak_enemy:
			push_error("En même temps on aurait pas ce problème si tu utilisais des classes")
			continue
		WwiseGlobal.cannon_workers.append(ak_enemy)
	print(WwiseGlobal.cannon_workers)
