@tool
class_name ShootRandom extends ActionLeaf

var is_shooting: bool = false
var shoot_start_time: int
const duration: float = 2

# TODO implement
func tick(_actor: Node, _blackboard: Blackboard) -> int:
	if not is_shooting:
		print("Start Shooting")
		is_shooting = true
		shoot_start_time = Time.get_ticks_msec()
		return RUNNING
	else:
		var elasped_timed: float = (Time.get_ticks_msec() - shoot_start_time) / 1000.0
		if elasped_timed > duration:
			print("Has Shoot") 
			is_shooting = false
			return SUCCESS
		else: 
			print("Is Shooting")
			return RUNNING

func interrupt(_actor: Node, _blackboard: Blackboard) -> void:
	is_shooting = false
