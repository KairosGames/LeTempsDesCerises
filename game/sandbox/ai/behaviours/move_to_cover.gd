class_name MoveToCover extends MoveAction

func get_stop_distance() -> float: return 0.2
func get_destination(actor: Node, blackboard: Blackboard) -> Vector3: return Vector3.ZERO
