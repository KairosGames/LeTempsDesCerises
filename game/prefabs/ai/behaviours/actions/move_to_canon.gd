@tool
class_name MoveToCanon extends MoveAction

func get_stop_distance() -> float: return 1.5
func get_destination(actor: Node, _blackboard: Blackboard) -> Vector3:
	return (actor as Agent).canon_slot.global_position
