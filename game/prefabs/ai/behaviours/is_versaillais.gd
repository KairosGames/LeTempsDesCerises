@tool
class_name IsVersallais extends ConditionLeaf

func tick(actor: Node, blackboard: Blackboard) -> int:
		return SUCCESS if (actor as Agent).team == Agent.Team.VERSALLAIS else FAILURE
