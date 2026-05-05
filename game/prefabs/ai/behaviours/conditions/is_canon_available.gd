@tool
class_name IsCanonAvailable extends ConditionLeaf

func tick(actor: Node, _blackboard: Blackboard) -> int:
	if not Canon.singleton: return FAILURE # TODO Remove prototyping guard
	if Canon.singleton.is_slot_available():
		var agent: Agent = actor
		agent.cover = null
		agent.canon_slot = Canon.singleton.take_slot(agent)
		return SUCCESS
	return FAILURE
