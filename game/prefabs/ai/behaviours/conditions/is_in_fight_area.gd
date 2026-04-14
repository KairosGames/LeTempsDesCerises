@tool
class_name IsInFightArea extends ConditionLeaf

func tick(actor: Node, _blackboard: Blackboard) -> int:
	var agent: Agent = actor
	var distance: float = agent.global_position.distance_to(GameManager.active_fight_area.global_position)
	if distance < GameManager.active_fight_area.size / 2.0: return SUCCESS
	else: return FAILURE
