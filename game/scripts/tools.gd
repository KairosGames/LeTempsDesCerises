class_name Tools


static func dt_lerp(speed: float, delta: float) -> float:
	return 1.0 - exp(-speed * delta)


static func get_yaw_to(pos: Vector3, target: Vector3, forward_offset: float = 0.0) -> float:
	var dir: Vector3 = target - pos
	dir.y = 0.0
	dir = dir.normalized()
	return atan2(-dir.x, -dir.z) + forward_offset


static func get_yaw_degree_to(pos: Vector3, target: Vector3, forward_offset: float = 0.0) -> float:
	return rad_to_deg(get_yaw_to(pos, target, forward_offset))
