@tool
class_name ChangeAimingState extends ActionLeaf

@export var is_aiming: bool

func tick(actor: Node, _blackboard: Blackboard) -> int:
	var agent: Agent = actor
	agent.is_aiming = is_aiming
	return SUCCESS
