@tool
class_name FindTarget extends ActionLeaf

@export_group("Limits")
@export var max_distance: float = 30
@export_group("Coefficient")
@export var versaillais: TargetSelectionCoefficient
@export var communard: TargetSelectionCoefficient

func get_targets(team : Agent.Team) -> Array[Node]:
	match team:
		Agent.Team.VERSAILLAIS: return get_tree().get_nodes_in_group(&"Communard")
		Agent.Team.COMMUNARD: return get_tree().get_nodes_in_group(&"Versaillais")
		_: return []

func tick(actor: Node, _blackboard: Blackboard) -> int:
	var agent: Agent = actor
	var raycast: RayCast3D = agent.shoot_raycast
	# TODO peeking
	# await agent.start_peek()

	var targets_data: Array = get_targets(agent.team).map(
		func(target: Node3D) -> TargetData:
			var data: TargetData = TargetData.new()
			data.target = target
			return data
	)

	for i in range(targets_data.size() -1, -1 -1):
		var distance: float = targets_data[i].target.global_position.distance_to(agent.global_position)
		if distance > max_distance: targets_data.remove_at(i)
		else: targets_data[i].distance = distance

	for i in range(targets_data.size() -1, -1 -1):
		var data: TargetData = targets_data[i]
		data.is_player = data.target is Player
		data.is_threatening = agent.threats.has(data.target)
		data.is_covered = not data.is_player and (data.target as Agent).is_covered
		data.is_pushing_canon = not data.is_player and (data.target as Agent).is_pushing_canon
		data.compute_score()

	targets_data.sort_custom(func(a: TargetData, b: TargetData) -> bool: return a.score > b.score )

	for data: TargetData in targets_data:
		if data.target is Player: continue
		for shoot_target: Marker3D in data.target.shoot_targets:
			raycast.look_at(shoot_target.global_position)
			raycast.force_raycast_update()
			if raycast.is_colliding():
				var collider: Object = raycast.get_collider()
				if collider is Agent or collider is Player:
					agent.target = data.target
					agent.target_point = shoot_target
					return SUCCESS

	return FAILURE

class TargetData:
	var target: Node3D

	var coefficents: TargetSelectionCoefficient
	var score: float

	var distance: float
	var is_player: bool
	var is_pushing_canon: bool
	var is_threatening: bool
	var is_covered: bool

	func compute_score() -> void:
		score = \
			distance * coefficents.distance + \
			int(is_player) * coefficents.player + \
			int(is_pushing_canon) * coefficents.canon + \
			int(is_threatening) * coefficents.threatening + \
			int(is_covered) * coefficents.covering
