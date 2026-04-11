@tool
class_name MoveToCover extends MoveAction

func get_stop_distance() -> float:
	return 0.2

func get_destination(_actor: Node, blackboard: Blackboard) -> Vector3: 
	return blackboard.get_value("cover").global_position

func has_succeeded(actor: Node, blackboard: Blackboard) -> int:
	var cover: Cover = blackboard.get_value("cover")
	if CoverManager.try_take_cover(cover):
		var agent: Agent = actor
		agent.is_covered = true
		return SUCCESS
	else: 
		return FAILURE
