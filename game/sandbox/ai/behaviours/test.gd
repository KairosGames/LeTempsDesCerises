class_name Test extends ConditionLeaf

func tick(actor: Node, blackboard: Blackboard) -> int:
	return RUNNING if not Input.is_key_pressed(KEY_SPACE) else FAILURE
	
