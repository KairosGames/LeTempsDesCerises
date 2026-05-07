@tool
class_name Shoot extends ActionLeaf

@export var max_angle_variation: float = 0
@export var vagueness_decrease: float = 2.0
var _vagueness: float = 1.0

func tick(actor: Node, _blackboard: Blackboard) -> int:
	var agent: Agent = actor
	var target: Node3D = agent.target
	var raycast: RayCast3D = agent.shoot_raycast
	
	if not target: return FAILURE
	
	# TODO? avait animation
	# return RUNNING
	
	raycast.global_position = agent.global_position + Vector3(0, 1.45, 0)
	raycast.look_at(target.global_position)
	
	var t: float = randf_range(0, TAU)
	var d: float = randf_range(0, max_angle_variation)
	var variation: Vector2 = Vector2(cos(t), sin(t)) * d * _vagueness
	raycast.rotation += Vector3(
		variation.y,
		variation.x
		,0
	)
	
	raycast.force_raycast_update()
	agent.is_weapon_loaded = false
	agent.shoot_anim()
	agent.shoot.emit()
	
	if raycast.is_colliding():
		var collider: Object = raycast.get_collider()
		if collider is Player or collider is Agent:
			collider.die()
			print("[%s] touched %s" % [agent.name, collider.name])
			_vagueness = 1.0
	else:
		_vagueness /= vagueness_decrease
		target.add_threat(agent)
	
	return SUCCESS
