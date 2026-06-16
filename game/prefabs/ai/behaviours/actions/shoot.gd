@tool
class_name Shoot extends ActionLeaf

@export var max_angle_variation: float = 2
@export var vagueness_decrease: float = 2.0
var _vagueness: float = 1.0

func tick(actor: Node, _blackboard: Blackboard) -> int:
	var agent: Agent = actor
	var raycast: RayCast3D = agent.shoot_raycast

	if not agent.target_object: return FAILURE

	# TODO USE a change posture action
	agent.posture = agent.cover.get_shoot_posture()
	var targ: Vector3 = agent.target_point.global_position
	targ.y = agent.global_position.y
	agent.look_at(targ)

	raycast.global_position = agent.global_position + Vector3(0, agent.cover.get_shoot_height(), 0)
	raycast.look_at(agent.target_point.global_position)

	var t: float = randf_range(0, TAU)
	var d: float = randf_range(0, deg_to_rad(max_angle_variation))
	raycast.rotation += Vector3(cos(t), sin(t), 0 ) * d * _vagueness

	raycast.force_raycast_update()
	agent.is_weapon_loaded = false
	agent.shoot_anim()
	agent.shoot.emit()
	var shoot_debug = get_node_or_null("/root/ShootDebug")
	if shoot_debug: shoot_debug.add_debug(
		raycast.global_position,
		raycast.global_rotation,
		Color.RED if agent.team == Agent.Team.COMMUNARD else Color.BLUE,
		false
	)

	if raycast.is_colliding():
		var collider: Object = raycast.get_collider()
		if collider is Player:
			var player: Player = collider as Player
			if not player.can_die: player.missed_by_enemy.emit()
			if player.is_immortal: player.missed_by_enemy.emit()
			if agent.team == Agent.Team.COMMUNARD: player.missed_by_enemy.emit()
			else:
				collider.die()
				_vagueness = 1.0
		elif collider is Agent:
			collider.die()
			_vagueness = 1.0
			var position: Vector3 = raycast.get_collision_point()
			var direction: Vector3 = raycast.get_collision_normal()
			EffectsManager.instance.impact_from_shoot.emit(position, direction, true)
		else:
			var position: Vector3 = raycast.get_collision_point()
			var direction: Vector3 = raycast.get_collision_normal()
			EffectsManager.instance.impact_from_shoot.emit(position, direction, false)
		return SUCCESS

	_vagueness /= vagueness_decrease
	if agent.target_object is Agent: (agent.target_object as Agent).add_threat(agent)
	elif agent.target_object is Player: (agent.target_object as Player).miss_by_versaillais()

	return SUCCESS
