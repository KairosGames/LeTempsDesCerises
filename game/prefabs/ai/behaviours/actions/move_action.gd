@tool
@abstract
class_name MoveAction extends ActionLeaf

@abstract func get_destination(actor: Node, blackboard: Blackboard) -> Vector3
@abstract func get_stop_distance() -> float

func tick(actor: Node, blackboard: Blackboard) -> int:
	var agent: Agent = actor
	var destination: Vector3 = get_destination(actor, blackboard)
	var stop_distance: float = get_stop_distance()
	if agent.navigation.target_position.distance_to(destination) > stop_distance: # handle moving target
		agent.navigation.move_to(destination, stop_distance)
	if agent.navigation.is_navigation_finished():
		return SUCCESS if agent.navigation.is_target_reached() else FAILURE
	else:
		return RUNNING

func interrupt(actor: Node, _blackboard: Blackboard) -> void:
	actor.navigation.stop()
