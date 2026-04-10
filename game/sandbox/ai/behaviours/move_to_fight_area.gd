@tool
class_name MoveToFightArea extends MoveAction

func get_destination(actor: Node, blackboard: Blackboard) -> Vector3: return GameManager.active_barricade.global_position
func get_stop_distance() -> float: return 15
