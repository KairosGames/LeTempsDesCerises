@tool
class_name FindTarget extends ActionLeaf

func tick(actor: Node, blackboard: Blackboard) -> int:
	var target: Node3D = null
	if target:
		blackboard.set_value("target", target)
		return SUCCESS
	else: 
		return FAILURE
