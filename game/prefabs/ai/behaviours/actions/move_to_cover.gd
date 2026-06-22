@tool
class_name MoveToCover extends MoveAction

@export var stop_distance: float = 0.5

var _is_rotating_to_cover: bool = false
var _rotation_finished: bool = false

func pre_condition(actor: Node, _blackboard: Blackboard) -> bool:
	var agent: Agent = actor
	return agent.cover != null

func get_stop_distance() -> float: return stop_distance
func get_destination(actor: Node, _blackboard: Blackboard) -> Vector3:
	return (actor as Agent).cover.global_position

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
	_is_rotating_to_cover = true
	_rotation_finished = false
	_rotate_to_cover(agent)

func _rotate_to_cover(agent: Agent) -> void:
	await agent.rotating_to(agent.cover.global_rotation.y, 0.5)
	_on_rotation_finished()

func interrupt(actor: Node, blackboard: Blackboard) -> void:
	_is_rotating_to_cover = false
	_rotation_finished = false
	super(actor, blackboard)

func _on_rotation_finished() -> void:
	_rotation_finished = true
