extends Node
# Cover -> IsFree
var _covers: Dictionary[Cover, bool]

func register(cover: Cover) -> void: _covers[cover] = true

func unregister(cover: Cover) -> void: _covers.erase(cover)

func try_take_cover(cover: Cover) -> bool:
	if _covers[cover]:
		_covers[cover] = false
		return true
	else:
		return false

func find_nearest_cover(agent_position: Vector3) -> Cover:
	var nearest: Cover = null
	var nearest_distance: float = 0
	for cover: Cover in _covers: # TODO spatial hashing
		if not nearest: 
			nearest = cover
			nearest_distance = agent_position.distance_squared_to(cover.global_position)
		else:
			var distance: float = agent_position.distance_squared_to(cover.global_position)
			if distance < nearest_distance:
				nearest = cover
				nearest_distance = distance
	return nearest

func find_closer_cover(agent_position: Vector3) -> Cover:
	var closest: Cover = null
	var closest_distance: float = 0
	
	return closest
