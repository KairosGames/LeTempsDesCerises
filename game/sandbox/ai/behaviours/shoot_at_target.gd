@tool
class_name ShootAtTarget extends ActionLeaf

var is_shooting: bool = false
var shoot_start_time: int
const duration: float = 2

# TODO implement
func tick(actor: Node, blackboard: Blackboard) -> int:
	var agent: Agent = actor
	var target: Node3D = blackboard.get_value("target", null)
	if not target: return FAILURE
	
	agent.aim_to(target.global_position)
	
	if not is_shooting:
		is_shooting = true
		shoot_start_time = Time.get_ticks_msec()
		return RUNNING
	else:
		var elasped_timed: float = (Time.get_ticks_msec() - shoot_start_time) / 1000.0
		if elasped_timed > duration:
			is_shooting = false
			(actor as Agent).animation.play("shoot")
			(actor as Agent).is_weapon_loaded = false
			return SUCCESS
		else: 
			return RUNNING

func interrupt(_actor: Node, _blackboard: Blackboard) -> void:
	is_shooting = false
