@tool
class_name IsOnTransitionCover extends ConditionLeaf

func tick(actor: Node, _blackboard: Blackboard) -> int:
	var agent: Agent = actor
	if not agent.cover or not is_instance_valid(agent.cover): return FAILURE
	return SUCCESS if agent.cover.type == Cover.Type.TRANSITORY else FAILURE
