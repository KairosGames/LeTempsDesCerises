@tool
class_name ShootAtTarget extends ActionLeaf

func tick(actor: Node, blackboard: Blackboard) -> int:
	var agent: Agent = actor
	
	var target: Node3D = blackboard.get_value("target", null)
	if not target: return FAILURE
	
	agent.look_at(target.global_position)
	print("Shoot at '%s'"%target.name) # TODO shoot animation, remove health
	
	return SUCCESS
