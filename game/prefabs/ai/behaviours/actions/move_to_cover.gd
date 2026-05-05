@tool
class_name MoveToCover extends MoveAction

func get_stop_distance() -> float: return 1
func get_destination(actor: Node, _blackboard: Blackboard) -> Vector3:
	return (actor as Agent).cover.global_position
