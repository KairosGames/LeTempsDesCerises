@tool
class_name Shoot extends ActionLeaf

@export var max_angle_variation: float = 2
@export var vagueness_decrease: float = 2.0
var _vagueness: float = 1.0

func tick(actor: Node, _blackboard: Blackboard) -> int:
	var agent: Agent = actor
	var raycast: RayCast3D = agent.shoot_raycast

	if not agent.target: return FAILURE

	agent.is_covered = false
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

	if raycast.is_colliding():
		var collider: Object = raycast.get_collider()
		if collider is Player or collider is Agent:
			collider.die()
			_vagueness = 1.0
			return SUCCESS

	_vagueness /= vagueness_decrease
	if agent.target is Agent: (agent.target as Agent).add_threat(agent)
	elif agent.target is Player: (agent.target as Player).miss_by_versaillais()

	return SUCCESS
