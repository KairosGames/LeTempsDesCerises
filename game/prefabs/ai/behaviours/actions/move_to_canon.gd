@tool
class_name MoveToCanon extends MoveAction

func get_stop_distance() -> float: return PushCanon.INTERACTION_DISTANCE * 0.8
func get_destination(actor: Node, _blackboard: Blackboard) -> Vector3:
	return (actor as Agent).canon_slot.global_position
