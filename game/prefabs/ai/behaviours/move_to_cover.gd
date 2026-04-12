@tool
class_name MoveToCover extends MoveAction

func get_stop_distance() -> float:
	return 1

func get_destination(_actor: Node, blackboard: Blackboard) -> Vector3:
	return blackboard.get_value("cover").global_position

func on_start(actor: Node, blackboard: Blackboard) -> int:
	var cover: Cover = blackboard.get_value("cover")
	if not cover or not CoverManager.try_take_cover(cover):
		return FAILURE
	else:
		(actor as Agent).cover = cover
		return RUNNING

# func has_succeeded(actor: Node, blackboard: Blackboard) -> int:
# 	var cover: Cover = blackboard.get_value("cover")
# 	if CoverManager.try_take_cover(cover):
# 		var agent: Agent = actor
# 		agent.cover = cover
# 		return SUCCESS
# 	else:
# 		return FAILURE
