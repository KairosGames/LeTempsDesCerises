@tool
class_name IsCommunard extends ConditionLeaf

func tick(actor: Node, _blackboard: Blackboard) -> int:
	return SUCCESS if (actor as Agent).team == Agent.Team.COMMUNARD else FAILURE
