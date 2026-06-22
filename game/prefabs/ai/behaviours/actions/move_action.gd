@tool
@abstract
class_name MoveAction extends ActionLeaf

@abstract func get_destination(actor: Node, blackboard: Blackboard) -> Vector3
@abstract func get_stop_distance() -> float

var _is_move_active: bool = false

func tick(actor: Node, blackboard: Blackboard) -> int:
	var agent: Agent = actor

	if not pre_condition(actor, blackboard):
		_stop_move(agent)
		return FAILURE

	var destination: Vector3 = get_destination(actor, blackboard)
	var stop_distance: float = get_stop_distance()

	if not agent.can_move:
		_stop_move(agent)
		return FAILURE

	if agent.navigation.target_position.distance_to(destination) > stop_distance: # handle moving target
		agent.navigation.move_to(destination, stop_distance)
		if not _is_move_active:
			_is_move_active = true
			agent.on_start_moving()
			on_start(actor, blackboard)
	if agent.navigation.is_navigation_finished():
		_stop_move(agent)
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
	_stop_move(actor as Agent)

func _stop_move(agent: Agent) -> void:
	if _is_move_active:
		_is_move_active = false
		agent.on_stop_moving()
	agent.navigation.stop()

func pre_condition(_actor: Node, _blackboard: Blackboard) -> bool: return true
func on_start(_actor: Node, _blackboard: Blackboard) -> void: pass
func on_success(_actor: Node, _blackboard: Blackboard) -> void: pass
func on_failure(_actor: Node, _blackboard: Blackboard) -> void: pass
