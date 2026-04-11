@tool
class_name MoveToCover extends MoveAction

func get_stop_distance() -> float: return 0.2
func get_destination(actor: Node, blackboard: Blackboard) -> Vector3: return blackboard.get_value("cover").global_position
