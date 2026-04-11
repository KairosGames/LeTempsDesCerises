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

# TODO optimise
func find_closer_cover(agent_position: Vector3) -> Cover:
	if not _covers.size(): return null
	
	if _covers.size() == 1: return _covers.keys()[0]
	
	var cover_distances: Array[CoverDistance] = _covers.keys().map(
		func(c) -> CoverDistance: 
			var cover_distance: CoverDistance = CoverDistance.new()
			cover_distance.cover = c
			cover_distance.distance = agent_position.distance_squared_to(c.global_position)
			return cover_distance
	)
	
	cover_distances.sort_custom(func(a: CoverDistance, b: CoverDistance) -> bool: return a.distance < b.distance)
	
	return cover_distances[0].cover if agent_position.distance_squared_to(cover_distances[0].cover.global_position) < \
	agent_position.distance_squared_to(cover_distances[0].cover.global_position) else cover_distances[1].cover

class CoverDistance:
	var cover: Cover
	var distance: float
