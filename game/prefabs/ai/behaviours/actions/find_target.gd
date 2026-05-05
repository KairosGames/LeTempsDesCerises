@tool
class_name FindTarget extends ActionLeaf

func tick(actor: Node, blackboard: Blackboard) -> int:
	var agent: Agent = actor
	var target: Node3D = null

	var available_targets: Array = get_tree().get_nodes_in_group(&"Entities")
	# TODO ? Fix for NEUTRAL
	available_targets = available_targets.filter(
		func(entity: Node3D) -> bool:
			return entity is Agent and entity.team != agent.team
	)
	available_targets.sort_custom(
		func(a: Node3D, b: Node3D) -> bool:
			return a.global_position.distance_squared_to(agent.global_position) \
			< b.global_position.distance_squared_to(agent.global_position)
	)

	if available_targets: target = available_targets[0]

	if target:
		blackboard.set_value("target", target)
		return SUCCESS
	else:
		return FAILURE
