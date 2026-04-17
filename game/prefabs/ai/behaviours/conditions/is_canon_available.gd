@tool
class_name IsCanonAvailable extends ConditionLeaf

func tick(_actor: Node, blackboard: Blackboard) -> int:
	for slot in Canon.singleton.slots:
		if not slot.get_child_count():
			blackboard.set_value("canon_slot", slot)
			return SUCCESS
	return FAILURE
