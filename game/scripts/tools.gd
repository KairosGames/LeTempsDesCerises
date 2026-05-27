class_name Tools


static func dt_lerp(speed: float, delta: float) -> float:
	return 1.0 - exp(-speed * delta)
