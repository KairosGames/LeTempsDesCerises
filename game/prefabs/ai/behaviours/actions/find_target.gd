@tool
class_name FindTarget extends ActionLeaf

func tick(actor: Node, blackboard: Blackboard) -> int:
	var agent: Agent = actor
	var target: Node3D = null
	
	var available_targets: Array = Agent.all
	# TODO ? Fix for NEUTRAL
	available_targets = available_targets.filter(func(a: Agent) -> bool: return agent.team != a.team)
	available_targets.sort_custom(func(a: Agent, b: Agent) -> bool: 
		return a.global_position.distance_squared_to(agent.global_position) \
		< b.global_position.distance_squared_to(agent.global_position)
	)
	
	if available_targets: target = available_targets[0]
	
	if target:
		blackboard.set_value("target", target)
		return SUCCESS
	else: 
		return FAILURE
