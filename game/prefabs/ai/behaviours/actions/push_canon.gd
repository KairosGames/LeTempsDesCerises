@tool
class_name PushCanon extends ActionLeaf

const INTERACTION_DISTANCE: float = 2

func tick(actor: Node, _blackboard: Blackboard) -> int:
	var agent: Agent = actor
	if not agent.is_pushing_canon:
		if agent.global_position.distance_to(agent.canon_slot.global_position) > INTERACTION_DISTANCE:
			return FAILURE
		agent.navigation.disable()
		agent.reparent(agent.canon_slot)
		agent.collision_mask = 0
		agent.transform = Transform3D.IDENTITY
		agent.is_pushing_canon = true
		return RUNNING
	else: 
		agent.transform = Transform3D.IDENTITY # FIXME
		return RUNNING
