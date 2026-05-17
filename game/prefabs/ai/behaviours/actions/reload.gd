@tool
class_name Reload extends ActionLeaf

@export var duration: float = 6
@export var duration_random: float = 2

var _is_reloading: bool = false
var _reloading_start_time: int

var _duration: float

func tick(actor: Node, _blackboard: Blackboard) -> int:
	var agent: Agent = actor

	if not _is_reloading:
		_duration = randf_range(duration - duration_random, duration + duration_random)
		_is_reloading = true
		_reloading_start_time = Time.get_ticks_msec()
		# FIXME
		# agent.is_covered = true
		agent.reload_anim()
		return RUNNING

	var elasped_timed: float = (Time.get_ticks_msec() - _reloading_start_time) / 1000.0

	if elasped_timed < _duration: return RUNNING

	_is_reloading = false

	agent.is_weapon_loaded = true

	return SUCCESS

func interrupt(_actor: Node, _blackboard: Blackboard) -> void:
	_is_reloading = false
