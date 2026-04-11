@tool
@abstract
class_name MoveAction extends ActionLeaf

@abstract func get_destination(actor: Node, blackboard: Blackboard) -> Vector3
@abstract func get_stop_distance() -> float

const MIN_DISTANCE: float = pow(0.5, 2)

func tick(actor: Node, blackboard: Blackboard) -> int:
	var agent: Agent = actor
	var destination: Vector3 = get_destination(actor, blackboard)
	
	if agent.navigation.target_position.distance_squared_to(destination) > MIN_DISTANCE:
		if agent.cover: 
			CoverManager.release(agent.cover)
			agent.cover = null
		agent.navigation.move_to(get_destination(actor, blackboard), get_stop_distance())
	
	if agent.navigation.is_navigation_finished():
		if agent.navigation.is_target_reached():
			return has_succeeded(actor, blackboard)
		else:
			on_failed(actor, blackboard)
			return FAILURE
	else:
		return is_running(actor, blackboard)
		

func interrupt(actor: Node, _blackboard: Blackboard) -> void:
	actor.navigation.stop()

func has_succeeded(_actor: Node, _blackboard: Blackboard) -> int: return SUCCESS
func on_failed(_actor: Node, _blackboard: Blackboard) -> void: return
func is_running(_actor: Node, _blackboard: Blackboard) -> int: return RUNNING
