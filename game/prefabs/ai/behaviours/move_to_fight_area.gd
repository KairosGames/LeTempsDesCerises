@tool
class_name MoveToFightArea extends MoveAction

func get_destination(_actor: Node, _blackboard: Blackboard) -> Vector3: return GameManager.active_barricade.global_position
func get_stop_distance() -> float: return 40
