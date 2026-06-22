@tool
class_name Reload extends ActionLeaf

@export var duration: float = 6
@export var duration_random: float = 2

var _reloading_start_time: int

var _duration: float

func tick(actor: Node, _blackboard: Blackboard) -> int:
	var agent: Agent = actor

	if not agent.is_reloading:
		_duration = randf_range(duration - duration_random, duration + duration_random)
		agent.is_reloading = true
		_reloading_start_time = Time.get_ticks_msec()
		return RUNNING

	var elasped_timed: float = (Time.get_ticks_msec() - _reloading_start_time) / 1000.0

	if elasped_timed < _duration: return RUNNING

	agent.is_reloading = false

	agent.is_weapon_loaded = true

	return SUCCESS

func interrupt(_actor: Node, _blackboard: Blackboard) -> void:
	agent.is_reloading = false
