@tool
class_name IsEnabled extends ConditionLeaf

func tick(actor: Node, _blackboard: Blackboard) -> int:
	var agent: Agent = actor
	return SUCCESS if not agent.is_disabled else FAILURE
