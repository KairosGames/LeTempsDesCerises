@tool
class_name HasEnemyInRange extends ConditionLeaf

func tick(actor: Node, _blackboard: Blackboard) -> int:
	var agent: Agent = actor
	return SUCCESS if agent.has_enemy_in_range else FAILURE
