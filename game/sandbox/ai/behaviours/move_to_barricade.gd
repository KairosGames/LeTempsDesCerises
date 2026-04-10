@tool
class_name MoveToBarricade extends ActionLeaf

var state: int = FAILURE
var cancelled := false
var run_id := 0

func tick(actor: Node, blackboard: Blackboard) -> int:
	if state != RUNNING:
		state = RUNNING
		cancelled = false
		run_id += 1
		_start_move(actor, blackboard, run_id)
	return state

func interrupt(actor: Node, _blackboard: Blackboard) -> void:
	cancelled = true
	run_id += 1
	state = FAILURE
	actor.navigation.stop()

func _start_move(agent: Agent, _blackboard: Blackboard, id: int) -> void:
	var destination: Vector3 = Flag.barricate_position
	agent.navigation.move_in_range(destination, 6)
	await agent.navigation.navigation_finished
	if cancelled or id != run_id: return
	state = SUCCESS if agent.navigation.is_target_reached() else FAILURE
