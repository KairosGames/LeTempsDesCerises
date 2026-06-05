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
	agent.look_at(agent.target_point.global_position)

	raycast.global_position = agent.global_position + Vector3(0, 1.45, 0)
	raycast.look_at(agent.target_point.global_position)

	var t: float = randf_range(0, TAU)
	var d: float = randf_range(0, deg_to_rad(max_angle_variation))
	raycast.rotation += Vector3(cos(t), sin(t), 0 ) * d * _vagueness

	raycast.force_raycast_update()
	agent.is_weapon_loaded = false
	agent.shoot_anim()
	agent.shoot.emit()
	if ShootDebug.instance: 
		ShootDebug.instance.add_debug(
			raycast.global_position,
			raycast.global_rotation,
			Color.RED if agent.team == Agent.Team.COMMUNARD else Color.BLUE, 
			false
		)

	if raycast.is_colliding():
		var collider: Object = raycast.get_collider()
		if collider is Player:
			if not (collider as Player).can_die:
				(collider as Player).missed_by_enemy.emit()
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
