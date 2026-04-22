@tool
class_name PushCanon extends ActionLeaf

var is_pushing: bool = false

func tick(actor: Node, blackboard: Blackboard) -> int:
	var agent: Agent = actor
	var slot: Marker3D = blackboard.get_value("canon_slot")
	if not is_pushing:
		if slot.get_child_count(): return FAILURE
		if agent.global_position.distance_to(slot.global_position) > 2: return FAILURE
		agent.navigation.disable()
		agent.get_parent().remove_child(agent)
		slot.add_child(agent)
		agent.collision_mask = 0
		agent.axis_lock_linear_x = true
		agent.axis_lock_linear_y = true
		agent.axis_lock_linear_z = true
		agent.axis_lock_angular_x = true
		agent.axis_lock_angular_y = true
		agent.axis_lock_angular_z = true
		agent.transform = Transform3D.IDENTITY
		is_pushing = true
		return RUNNING
	else: 
		agent.transform = Transform3D.IDENTITY
		return RUNNING
