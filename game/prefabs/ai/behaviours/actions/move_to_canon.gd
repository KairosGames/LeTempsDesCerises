@tool
class_name MoveToCanon extends MoveAction

func get_stop_distance() -> float: return 1.5
func get_destination(_actor: Node, blackboard: Blackboard) -> Vector3: return blackboard.get_value("canon_slot").global_position
