@tool
class_name IsWeaponLoaded extends ConditionLeaf

func tick(actor: Node, _blackboard: Blackboard) -> int:
	var agent: Agent = actor
	return SUCCESS if agent.is_weapon_loaded else FAILURE
