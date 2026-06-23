@tool
class_name MoveToCover extends MoveAction

@export var stop_distance: float = 0.5

var _is_rotating_to_cover: bool = false
var _rotation_finished: bool = false

func pre_condition(actor: Node, _blackboard: Blackboard) -> bool:
	return _get_target_cover(actor as Agent) != null

func get_stop_distance() -> float: return stop_distance
func get_destination(actor: Node, _blackboard: Blackboard) -> Vector3:
	return _get_target_cover(actor as Agent).global_position

func tick(actor: Node, blackboard: Blackboard) -> int:
	var agent: Agent = actor

	if _is_rotating_to_cover:
		if _rotation_finished:
			_is_rotating_to_cover = false
			_rotation_finished = false
			return SUCCESS
		return RUNNING

	return super(actor, blackboard)

func on_success(actor: Node, _blackboard: Blackboard) -> void:
	var agent: Agent = actor
	var target_cover: Cover = _get_target_cover(agent)
	if agent.cover_destination and target_cover:
		agent.cover = target_cover
		agent.cover_destination = null
	_is_rotating_to_cover = true
	_rotation_finished = false
	_rotate_to_cover(agent)

func _rotate_to_cover(agent: Agent) -> void:
	await agent.rotating_to(agent.cover.global_rotation.y, 0.5)
	_on_rotation_finished()

func on_failure(actor: Node, _blackboard: Blackboard) -> void:
	var agent: Agent = actor
	if agent.cover_destination:
		agent.cover_destination = null

func interrupt(actor: Node, blackboard: Blackboard) -> void:
	var agent: Agent = actor
	_is_rotating_to_cover = false
	_rotation_finished = false
	if agent.cover_destination:
		agent.cover_destination = null
	super(actor, blackboard)

func _on_rotation_finished() -> void:
	_rotation_finished = true

func _get_target_cover(agent: Agent) -> Cover:
	if not agent: return null
	if agent.cover_destination and is_instance_valid(agent.cover_destination):
		return agent.cover_destination
	return agent.cover if is_instance_valid(agent.cover) else null
