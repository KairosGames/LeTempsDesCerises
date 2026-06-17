@tool
class_name MoveToCover extends MoveAction

@export var stop_distance: float = 0.5

func pre_condition(actor: Node, _blackboard: Blackboard) -> bool:
	var agent: Agent = actor
	return agent.cover != null

func get_stop_distance() -> float: return stop_distance
func get_destination(actor: Node, _blackboard: Blackboard) -> Vector3:
	return (actor as Agent).cover.global_position

func on_success(actor: Node, _blackboard: Blackboard) -> void:
	var agent: Agent = actor
	agent.rotating_to(agent.cover.global_rotation.y, 0.5)
