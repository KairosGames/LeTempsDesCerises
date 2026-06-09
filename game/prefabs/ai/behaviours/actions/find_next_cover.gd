@tool
class_name FindNextCover extends ActionLeaf

func tick(actor: Node, _blackboard: Blackboard) -> int:
	var agent: Agent = actor
	var current_cover: Cover = agent.cover

	if not current_cover: return FAILURE

	var covers: Array[Cover] = current_cover.next_covers.duplicate()

	for i in range(covers.size() -1, -1, -1):
		if not (covers[i] as Cover).is_cover_available(): covers.remove_at(i)

	if not covers.size(): return FAILURE

	var next_cover: Cover = covers.pick_random()

	agent.cover = next_cover
	return SUCCESS
