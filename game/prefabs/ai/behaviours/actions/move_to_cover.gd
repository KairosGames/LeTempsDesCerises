@tool
class_name MoveToCover extends MoveAction

@export var stop_distance: float = 0.5

func get_stop_distance() -> float: return stop_distance
func get_destination(actor: Node, _blackboard: Blackboard) -> Vector3:
	return (actor as Agent).cover.global_position
