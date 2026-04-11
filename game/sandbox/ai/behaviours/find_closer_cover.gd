@tool
class_name FindCloserCover extends ActionLeaf

func tick(actor: Node, blackboard: Blackboard) -> int:
	var agent: Agent = actor
	var closer_cover: Cover = CoverManager.find_closer_cover(agent.global_position)
	if closer_cover:
		blackboard.set_value("cover", closer_cover)
		return SUCCESS
	else:
		return FAILURE
