@tool
class_name MoveToFightArea extends MoveAction

func get_destination(_actor: Node, _blackboard: Blackboard) -> Vector3: return GameManager.active_fight_area.global_position
func get_stop_distance() -> float: return GameManager.active_fight_area.size / 2.0
