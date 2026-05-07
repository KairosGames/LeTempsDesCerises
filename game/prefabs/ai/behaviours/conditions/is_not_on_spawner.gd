@tool
class_name IsNotOnSpawner extends ConditionLeaf

func tick(actor: Node, _blackboard: Blackboard) -> int:
	var agent: Agent = actor
	return FAILURE if agent.cover.type == Cover.Type.SPAWNER else SUCCESS
