@tool
@icon("res://addons/beehave/icons/delayer.svg")
class_name Wait extends ActionLeaf

@export var duration: float = 1.5
@export var duration_random: float = 0.5

@export_enum("SUCCESS", "FAILURE", "RUNNING") var result: int

var _is_waiting: bool = false
var timer: Timer = Timer.new()

func _ready() -> void:
	timer.one_shot = true
	timer.autostart = false
	add_child(timer)

func tick(_actor: Node, _blackboard: Blackboard) -> int:
	if not _is_waiting:
		_is_waiting = true
		var test_duration: float = randf_range(duration - duration_random, duration + duration_random)
		timer.start(test_duration)
		return RUNNING
	elif timer.time_left:
		return RUNNING
	else:
		_is_waiting = false
		return result

func interrupt(_actor: Node, _blackboard: Blackboard) -> void:
	_is_waiting = false
	timer.stop()
