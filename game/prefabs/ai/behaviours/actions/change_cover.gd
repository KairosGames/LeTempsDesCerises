@tool
class_name ChangeCover extends ActionLeaf

@export var is_covered: bool

func tick(actor: Node, _blackboard: Blackboard) -> int:
	var agent: Agent = actor
	# FIXME
	# agent.is_covered = is_covered
	return SUCCESS
