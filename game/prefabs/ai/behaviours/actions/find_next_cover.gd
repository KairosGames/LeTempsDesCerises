@tool
class_name FindNextCover extends ActionLeaf

func tick(actor: Node, _blackboard: Blackboard) -> int:
	var agent: Agent = actor
	var current_cover: Cover = agent.cover
	if not current_cover: return FAILURE
	for next_cover: Cover in current_cover.next_covers:
		if next_cover.enabled and not next_cover.holder:
			agent.cover = next_cover
			return SUCCESS
	return FAILURE
