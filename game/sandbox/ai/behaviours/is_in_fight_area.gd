@tool
class_name IsInFightArea extends ConditionLeaf

func tick(actor: Node, _blackboard: Blackboard) -> int:
	var agent: Agent = actor
	var distance: float = agent.global_position.distance_to(GameManager.active_barricade.global_position)
	if distance < 30: return SUCCESS
	else: return FAILURE
