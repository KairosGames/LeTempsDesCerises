extends Node
# Cover -> IsFree
var _covers: Dictionary[Cover, bool]

func is_free(cover: Cover) -> bool:
	return _covers[cover]

func register(cover: Cover) -> void: _covers[cover] = true

func unregister(cover: Cover) -> void: _covers.erase(cover)

func release(cover: Cover) -> void:
	_covers[cover] = true
	
func try_take_cover(cover: Cover) -> bool:
	if not _covers.has(cover): return false
	if _covers[cover]:
		_covers[cover] = false
		return true
	else:
		return false

func find_nearest_cover(agent: Agent) -> Cover:
	var available_covers: Array = _covers.keys()
	if agent.cover: available_covers.erase(agent.cover)
	available_covers = available_covers.filter(func(cover) -> bool: return _covers[cover])
	
	if not available_covers.size(): return null
	if available_covers.size() == 1: return available_covers[0]
	
	var nearest: CoverDistance = null
	for cover: Cover in available_covers: # TODO spatial hashing
		var distance: float = agent.global_position.distance_squared_to(cover.global_position)
		if not nearest or distance < nearest.distance: 
			nearest = CoverDistance.new()
			nearest.cover = cover
			nearest.distance = distance
	return nearest.cover

func find_closer_cover(agent: Agent) -> Cover:
	var available_covers: Array = _covers.keys()
	if agent.cover: available_covers.erase(agent.cover)
	available_covers = available_covers.filter(func(cover) -> bool: return _covers[cover])
	
	if not available_covers.size(): return null
	if available_covers.size() == 1: return available_covers[0]
	
	var barricade_position: Vector3 = GameManager.active_fight_area.global_position
	
	var covers_distances_to_barricade: Array = available_covers.map(
		func(cover) -> CoverDistance: 
			var cover_distance: CoverDistance = CoverDistance.new()
			cover_distance.cover = cover
			cover_distance.distance = barricade_position.distance_squared_to(cover.global_position)
			return cover_distance
	)
	
	var distance_to_barricade: float= agent.global_position.distance_squared_to(barricade_position)
	
	covers_distances_to_barricade = covers_distances_to_barricade.filter(
		func(cover_distance_to_barricade: CoverDistance) -> bool: 
			return cover_distance_to_barricade.distance < distance_to_barricade
	)
	
	if not covers_distances_to_barricade.size(): return null
	if covers_distances_to_barricade.size() == 1: return covers_distances_to_barricade[0].cover
	
	covers_distances_to_barricade.sort_custom(
		func(a: CoverDistance, b: CoverDistance) -> bool:
			return agent.global_position.distance_squared_to(a.cover.global_position) \
			< agent.global_position.distance_squared_to(b.cover.global_position)
	)
	
	return covers_distances_to_barricade[0].cover

class CoverDistance:
	var cover: Cover
	var distance: float
