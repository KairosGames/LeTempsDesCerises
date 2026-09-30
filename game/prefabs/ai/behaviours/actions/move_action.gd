@tool
@abstract
class_name MoveAction extends ActionLeaf

@abstract func get_destination(actor: Node, blackboard: Blackboard) -> Vector3
@abstract func get_stop_distance() -> float

var tick_elapsed: float
var start_position: Vector3

func tick(actor: Node, blackboard: Blackboard) -> int:
	var agent: Agent = actor

	if not pre_condition(actor, blackboard):
		if agent:
			agent.on_stop_moving()
			agent.navigation.stop()
		return FAILURE

	var destination: Vector3 = get_destination(actor, blackboard)
	var stop_distance: float = get_stop_distance()

	if not agent.can_move: return FAILURE

	if agent.navigation.target_position.distance_to(destination) > stop_distance: # handle moving target
		start_position = agent.global_position
		tick_elapsed = 0
		agent.navigation.move_to(destination, stop_distance)
		agent.on_start_moving()
		on_start(actor, blackboard)
		tick_elapsed += 1.0 * Engine.time_scale
		return RUNNING

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
		var distance: float = start_position.distance_to(destination)
		var theorical_tick_duration: float = distance / 4.0 * 60.0 * 5.0
		if distance > stop_distance and tick_elapsed > theorical_tick_duration:
			print("Blocked agent killed: distance: %s, tick: %s" % [distance, tick_elapsed])
			push_warning("Blocked agent killed: distance: %s, tick: %s" % [distance, tick_elapsed])
			agent.die()
			return FAILURE
		tick_elapsed += 1.0 * Engine.time_scale
		return RUNNING

func interrupt(actor: Node, _blackboard: Blackboard) -> void:
	var agent: Agent = actor
	agent.on_stop_moving()
	agent.navigation.stop()
	tick_elapsed = 0
	start_position = Vector3.ZERO

func pre_condition(_actor: Node, _blackboard: Blackboard) -> bool: return true
func on_start(_actor: Node, _blackboard: Blackboard) -> void: pass
func on_success(_actor: Node, _blackboard: Blackboard) -> void: pass
func on_failure(_actor: Node, _blackboard: Blackboard) -> void: pass
