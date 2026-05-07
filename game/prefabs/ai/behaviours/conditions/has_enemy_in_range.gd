@tool
class_name HasEnemyInRange extends ConditionLeaf

@export var max_distance: float = 40

func get_targets(team : Agent.Team) -> Array[Node]:
	match team:
		Agent.Team.VERSAILLAIS: return get_tree().get_nodes_in_group(&"Communard")
		Agent.Team.COMMUNARD: return get_tree().get_nodes_in_group(&"Versaillais")
		_: return []

func tick(actor: Node, _blackboard: Blackboard) -> int:
	var agent: Agent = actor
	
	var targets_data: Array = get_targets(agent.team)
	
	for i in range(targets_data.size()):
		if targets_data[i] is Player and not (targets_data[i] as Player).is_alive:
			continue
		var distance: float = targets_data[i].target.global_position.distance_to(agent.global_position)
		if distance > max_distance: continue
		else:
			agent.has_enemy_in_range = true
			return SUCCESS
	
	agent.has_enemy_in_range = false
	
	return FAILURE
