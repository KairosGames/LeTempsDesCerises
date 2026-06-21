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
	var coefficents: TargetSelectionCoefficient
	match agent.team:
		Agent.Team.VERSAILLAIS: coefficents = versaillais
		Agent.Team.COMMUNARD: coefficents = communard

	var targets_data: Array = get_targets(agent.team).map(
		func(target: Node3D) -> TargetData: return TargetData.new(target, agent, coefficents)
	)

	# TODO if target is Player always do raycast

	for i: int in range(targets_data.size() -1, -1 -1):
		var data: TargetData = targets_data[i]
		@warning_ignore("unsafe_property_access")
		if not data.target.is_alive or data.target is Agent and not data.target.can_die:
			targets_data.remove_at(i)
			continue
		if data.distance > max_distance:
			targets_data.remove_at(i)

	agent.has_enemy_in_range = targets_data.size()
	if not agent.has_enemy_in_range:
		return FAILURE

	targets_data.sort_custom(best_score)

	for data: TargetData in targets_data:
		@warning_ignore("unsafe_property_access")
		for shoot_target: Marker3D in data.target.shoot_targets:
			raycast.global_position = agent.global_position + Vector3(0, agent.get_shoot_height(), 0)
			raycast.look_at(shoot_target.global_position)
			raycast.force_raycast_update()
			@warning_ignore("untyped_declaration")
			var shoot_debug = get_node_or_null("/root/ShootDebug")
			@warning_ignore("unsafe_method_access")
			if shoot_debug: shoot_debug.add_debug(
				raycast.global_position,
				raycast.global_rotation,
				Color.ORANGE if agent.team == Agent.Team.COMMUNARD else Color.CYAN,
				false
			)
			if raycast.is_colliding():
				var collider: Object = raycast.get_collider()
				if collider is Agent or collider is Player:
					agent.target_object = data.target
					agent.target_point = shoot_target
					return SUCCESS

	return FAILURE

static func best_score(a: TargetData, b: TargetData) -> bool: return a.score < b.score

class TargetData:

	func _init(target: Node3D, agent: Agent, coefficents: TargetSelectionCoefficient) -> void:

		self.target = target

		is_player = target is Player
		is_threatening = agent.threats.has(target)
		is_pushing_canon = not is_player and (target as Agent).is_pushing_canon
		distance = target.global_position.distance_to(agent.global_position)

		covering = 0.0 if is_player or not target.cover else target.cover.get_cover_posture() / float(target.posture)

		score = \
			distance * coefficents.distance + \
			covering * coefficents.covering + \
			int(is_player) * coefficents.player + \
			int(is_pushing_canon) * coefficents.canon + \
			int(is_threatening) * coefficents.threatening

	var target: Node3D

	var score: float

	var covering: float
	var is_player: bool
	var is_pushing_canon: bool

	var distance: float
	var is_threatening: bool
