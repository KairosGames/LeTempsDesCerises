@tool
@icon("res://addons/beehave/icons/delayer.svg")
class_name Wait extends ActionLeaf

@export var duration: float = 1.5
@export var duration_random: float = 0.5

@export_enum("SUCCESS", "FAILURE", "RUNNING") var result: int

var _is_waiting: bool = false
var _start_time: int
var _duration: float = 0

func tick(_actor: Node, _blackboard: Blackboard) -> int:
	if not _is_waiting:
		_duration = randf_range(duration - duration_random, duration + duration_random)
		_start_time = Time.get_ticks_msec()
		_is_waiting = true
		return RUNNING
	var elasped_timed: float = (Time.get_ticks_msec() - _start_time) / 1000.0
	if elasped_timed < _duration: return RUNNING
	_is_waiting = false
	return result

func interrupt(_actor: Node, _blackboard: Blackboard) -> void:
	_is_waiting = false
