@tool
class_name HasCanonSlot extends ConditionLeaf

func tick(actor: Node, _blackboard: Blackboard) -> int:
	var agent: Agent = actor
	return SUCCESS if agent.canon_slot else FAILURE
