@tool
class_name Reload extends ActionLeaf

var is_reloading: bool = false
var reloading_start_time: int
# TODO random_between 4 and 8 and iteruption
const duration: float = 4

func tick(_actor: Node, _blackboard: Blackboard) -> int:
	if not is_reloading:
		print("Reloading") # TODO play reload animation
		is_reloading = true
		reloading_start_time = Time.get_ticks_msec()
		return RUNNING
	else:
		var elasped_timed: float = (Time.get_ticks_msec() - reloading_start_time) / 1000.0
		if elasped_timed > duration: 
			is_reloading = false
			return SUCCESS
		else: return RUNNING

func interrupt(_actor: Node, _blackboard: Blackboard) -> void:
	is_reloading = false
