@tool
class_name Shoot extends ActionLeaf

var _vagueness: float = 1.0

func tick(actor: Node, _blackboard: Blackboard) -> int:
	var agent: Agent = actor

	var max_angle_variation: float = max(0, GameManager.instance.max_angle_variations[agent.team] if GameManager.instance else 2.0)
	var vagueness_decrease: float = max(1, GameManager.instance.vagueness_decreases[agent.team] if GameManager.instance else 2.0)

	var raycast: RayCast3D = agent.shoot_raycast

	if not agent.target_object: return FAILURE

	# TODO USE a change posture action
	agent.posture = agent.get_shoot_posture()
	var targ: Vector3 = agent.target_point.global_position
	targ.y = agent.global_position.y
	var dir: Vector3 = agent.global_position.direction_to(targ)
	agent.rotating_to(atan2(-dir.x, -dir.z), 0.3)

	raycast.global_position = agent.global_position + Vector3(0, agent.get_shoot_height(), 0)
	raycast.look_at(agent.target_point.global_position)

	var t: float = randf_range(0, TAU)
	var d: float = randf_range(0, deg_to_rad(max_angle_variation))
	raycast.rotation += Vector3(cos(t), sin(t), 0 ) * d * _vagueness

	raycast.force_raycast_update()
	agent.is_weapon_loaded = false
	agent.shoot_anim()
	agent.shoot.emit()
	@warning_ignore("untyped_declaration")
	var shoot_debug = get_node_or_null("/root/ShootDebug")
	@warning_ignore("unsafe_method_access")
	if shoot_debug: shoot_debug.add_debug(
		raycast.global_position,
		raycast.global_rotation,
		Color.RED if agent.team == Agent.Team.COMMUNARD else Color.BLUE,
		false
	)

	if raycast.is_colliding():
		var collider: Object = raycast.get_collider()
		var position: Vector3 = raycast.get_collision_point()
		var coll_dir: Vector3 = raycast.get_collision_normal()
		var coll_rot: Vector3 = Basis.looking_at(coll_dir.normalized(), Vector3.UP, true).get_euler()
		var shoot_dir: Vector3 = -raycast.global_transform.basis.z.normalized()
		agent.chassepot.play_light_trail(position)
		if collider is Player:
			var player: Player = collider as Player
			if not player.can_die: player.missed_by_enemy.emit()
			if player.is_immortal: player.missed_by_enemy.emit()
			if agent.team == Agent.Team.COMMUNARD: player.missed_by_enemy.emit()
			else:
				if player.can_die and not player.is_immortal: EffectsManager.instance.play_effect(EffectsManager.EffectType.BloodImpact, position, coll_rot)
				(collider as Player).die()
				_vagueness = 1.0
		elif collider is Agent:
			var other_agent: Agent = collider
			if other_agent.can_die: EffectsManager.instance.play_effect(EffectsManager.EffectType.BloodImpact, position, coll_rot)
			if agent.team != other_agent.team: other_agent.die()
			_vagueness = 1.0
		else:
			EffectsManager.instance.impact_from_shoot.emit(position, shoot_dir, false)
		return SUCCESS
	var dest: Vector3 = agent.chassepot.global_position + (agent.chassepot.shoot_light_trail.basis.z * 100.0)
	agent.chassepot.play_light_trail(dest)
	_vagueness /= vagueness_decrease
	if agent.target_object is Agent: (agent.target_object as Agent).add_threat(agent)
	elif agent.target_object is Player: (agent.target_object as Player).miss_by_versaillais()

	return SUCCESS
