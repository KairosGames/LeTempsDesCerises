@tool
@abstract
class_name MoveAction extends ActionLeaf

@abstract func get_destination(actor: Node, blackboard: Blackboard) -> Vector3
@abstract func get_stop_distance() -> float

func tick(actor: Node, blackboard: Blackboard) -> int:
	var agent: Agent = actor
	var destination: Vector3 = get_destination(actor, blackboard)
	var stop_distance: float = get_stop_distance()
	
	if not agent.can_move: return FAILURE
	
	if agent.navigation.target_position.distance_to(destination) > stop_distance: # handle moving target
		agent.navigation.move_to(destination, stop_distance)
		agent.on_start_moving()
		on_start(actor, blackboard)
	if agent.navigation.is_navigation_finished():
		agent.on_stop_moving()
		var is_target_reached: bool = agent.navigation.is_target_reached()
		if is_target_reached:
			on_success(actor, blackboard)
			return SUCCESS
		else:
			on_failure(actor, blackboard)
			return FAILURE
	else:
		return RUNNING

func interrupt(actor: Node, _blackboard: Blackboard) -> void:
	var agent: Agent = actor
	agent.on_stop_moving()
	agent.navigation.stop()

func on_start(_actor: Node, _blackboard: Blackboard) -> void: pass
func on_success(_actor: Node, _blackboard: Blackboard) -> void: pass
func on_failure(_actor: Node, _blackboard: Blackboard) -> void: pass
