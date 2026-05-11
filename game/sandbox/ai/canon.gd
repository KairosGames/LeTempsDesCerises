class_name Canon extends PathFollow3D

static var singleton: Canon

signal shoot
signal start_move
signal stop_move

@export_custom(PROPERTY_HINT_NONE,"suffix: m/s") var speeds: Array[float] = [0, 0.25, 0.5, 1]
@export_custom(PROPERTY_HINT_NONE,"suffix: s") var shoot_delay: float = 5
@export var max_recruitment_range: float = 30

var available_slots: Array[Marker3D] = []
var holded_slots: Array[Marker3D] = []

@onready var _slots: Array[Marker3D] = [%Slot0, %Slot1, %Slot2]

var _last_shoot_time: float

func _ready() -> void:
	singleton = self
	available_slots = _slots.duplicate()

func _physics_process(delta: float) -> void:
	_find_workers()
	progress += speeds[holded_slots.size()] * delta
	if progress_ratio == 1 and (Time.get_ticks_msec() - _last_shoot_time) > shoot_delay * 1000:
		print("[Canon] shoot")
		_last_shoot_time = Time.get_ticks_msec()
		shoot.emit()

func _find_workers() -> void:
	if available_slots.size():
		var nearest_agent: Agent = null
		var nearest_distance: float = 0
		for agent: Agent in get_tree().get_nodes_in_group(&"Versaillais"):
			if agent.canon_slot: continue
			var distance: float = agent.global_position.distance_squared_to(global_position)
			if distance > max_recruitment_range: continue
			if not nearest_agent or  distance< nearest_distance:
				nearest_agent = agent
				nearest_distance = distance
		if nearest_agent:
			nearest_agent.canon_slot = _take_slot(nearest_agent)

func is_slot_available() -> bool: return available_slots.size()

func _take_slot(agent: Agent) -> Marker3D:
	var slot: Marker3D = available_slots.pop_front()
	holded_slots.push_back(slot)
	if holded_slots.size() == 1: start_move.emit()
	agent.died.connect(_restore.bind(slot))
	return slot

func _restore(_agent: Agent, slot: Marker3D) -> void:
	holded_slots.erase(slot)
	available_slots.push_back(slot)
	if not holded_slots.size(): stop_move.emit()
