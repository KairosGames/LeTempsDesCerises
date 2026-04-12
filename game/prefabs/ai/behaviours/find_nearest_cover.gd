@tool
class_name FindNearestCover extends ActionLeaf

func tick(actor: Node, blackboard: Blackboard) -> int:
	var agent: Agent = actor
	var nearest_cover: Cover = CoverManager.find_nearest_cover(agent)
	if nearest_cover:
		blackboard.set_value("cover", nearest_cover)
		return SUCCESS
	else:
		return FAILURE
