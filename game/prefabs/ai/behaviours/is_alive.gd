@tool
class_name IsAlive extends ConditionLeaf

func tick(actor: Node, _blackboard: Blackboard) -> int:
	return SUCCESS if (actor as Agent).is_alive else FAILURE
