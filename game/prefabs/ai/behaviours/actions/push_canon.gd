@tool
class_name PushCanon extends ActionLeaf

const INTERACTION_DISTANCE: float = 2

var _previous_parent: Node
var _previous_global_transform: Transform3D
var _previous_collision_mask: int = 0
var _previous_avoidance_enabled: bool = true

func tick(actor: Node, _blackboard: Blackboard) -> int:
	var agent: Agent = actor
	if not agent.is_working_on_cannon:
		if agent.global_position.distance_to(agent.canon_slot.global_position) > INTERACTION_DISTANCE:
			return FAILURE
		_previous_parent = agent.get_parent()
		_previous_global_transform = agent.global_transform
		_previous_collision_mask = agent.collision_mask
		_previous_avoidance_enabled = agent.navigation.avoidance_enabled
		agent.navigation.disable()
		agent.reparent(agent.canon_slot)
		agent.collision_mask = 0
		agent.transform = Transform3D.IDENTITY
		agent.is_working_on_cannon = true
		agent.is_pushing_canon = agent.canon_slot.get_index() != 0
		agent.is_pulling_canon = agent.canon_slot.get_index() == 0
		return RUNNING
	else:
		agent.transform = Transform3D.IDENTITY # FIXME
		return RUNNING

func interrupt(actor: Node, _blackboard: Blackboard) -> void:
	var agent: Agent = actor
	if agent.is_working_on_cannon:
		agent.is_working_on_cannon = false
		agent.collision_mask = _previous_collision_mask
		agent.navigation.avoidance_enabled = _previous_avoidance_enabled
		if _previous_parent and is_instance_valid(_previous_parent) and agent.get_parent() != _previous_parent:
			agent.reparent(_previous_parent)
			agent.global_transform = _previous_global_transform
	_previous_parent = null
