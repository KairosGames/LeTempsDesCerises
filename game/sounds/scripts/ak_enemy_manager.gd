extends Node3D

@export var versaillais : Node3D
@export var shoot : AkEvent3D
@export var steps : AkEvent3D

func _enter_tree() -> void:
	BarksManager.register(self, "enemy")

func _on_versaillais_shoot() -> void:
	shoot.post_event()

func _on_versaillais_move_start() -> void:
	steps.post_event()

func _on_versaillais_move_end() -> void:
	steps.stop_event()

func _on_communard_shoot() -> void:
	shoot.post_event()

func _on_versaillais_died(agent: Agent) -> void:
	BarksManager.remove(self)
