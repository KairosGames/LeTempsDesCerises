@tool
class_name CanMove extends ConditionLeaf

func tick(actor: Node, _blackboard: Blackboard) -> int:
	return SUCCESS if (actor as Agent).can_move else FAILURE
