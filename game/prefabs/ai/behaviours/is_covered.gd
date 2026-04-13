@tool
class_name IsCovered extends ConditionLeaf

func tick(actor: Node, _blackboard: Blackboard) -> int:
	var agent: Agent = actor
	return SUCCESS if agent.cover else FAILURE
