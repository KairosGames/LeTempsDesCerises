class_name Canon extends PathFollow3D

static var singleton: Canon

signal start_move
signal stop_move
signal start_reload
signal reloaded
signal shoot
signal workers_updated(workers: Array[Agent])
signal move_progress_changed(float)
signal reload_progress_changed(float)

@onready var objective_point: Marker3D = %ObjectivePoint
@onready var second_path: Path3D = %Path3DCannon2

@export_custom(PROPERTY_HINT_NONE,"suffix: m/s") var move_speeds: Array[float] = [0, 0, 0.5, 1]
@export_custom(PROPERTY_HINT_NONE,"suffix: s") var reload_duration: Array[float] = [0, 15, 10, 5]
@export_custom(PROPERTY_HINT_NONE,"suffix: s") var patience: float = 10
@export_custom(PROPERTY_HINT_NONE,"suffix: s") var delay_before_shoot: float = 3
@export var recruitment_range_boost: float = 4
@export var max_recruitment_range: float = 30

var workers: Array[Agent]
var available_slots: Array[Marker3D] = []
var holded_slots: Array[Marker3D] = []

var move_progress: float:
	set(value):
		move_progress = clampf(value, 0.0, 1.0)
		move_progress_changed.emit(move_progress)

var reload_progress: float:
	set(value):
		reload_progress = clampf(value, 0.0, 1.0)
		reload_progress_changed.emit(reload_progress)

@onready var _slots: Array[Marker3D] = [%Slot0, %Slot1, %Slot2]

var _time_without_worker: float
var _is_first_shoot: bool = true
var _state: State = State.MOVING

var is_first_activation: bool = true
var enabled: bool = false:
	set(value):
		enabled = value
		if is_first_activation and enabled and not workers.size():
			is_first_activation = false
			_create_workers()

const WORKER_PREFAB: PackedScene = preload("uid://d28tbnqpob3um")

func _ready() -> void:
	singleton = self
	available_slots = _slots.duplicate()

func _physics_process(delta: float) -> void:
	if not enabled: return
	
	if is_slot_available():
		var recruitment_range = max_recruitment_range * recruitment_range_boost if _time_without_worker > patience else max_recruitment_range
		var new_worker: Agent = _find_workers(recruitment_range)
		if new_worker: 
			var slot: Marker3D = _take_slot(new_worker)
			new_worker.canon_slot = slot
			workers.append(new_worker)
			workers_updated.emit(workers)
			_time_without_worker = 0
		else: _time_without_worker += delta
	
	match _state:
		State.MOVING:
			progress += move_speeds[workers.size()] * delta
			move_progress = progress_ratio
			if move_progress == 1.0: _state = State.RELOADING
		State.RELOADING:
			if reload_progress < 1.0:
				if reload_progress == 0.0: start_reload.emit()
				reload_progress += delta / reload_duration[workers.size()]
				if reload_progress == 1.0: 
					#stop_reload.emit()
					reloaded.emit()
					_shoot()

func _shoot() -> void:
	if _is_first_shoot:
		_is_first_shoot = false
		await GameManager.instance.all_states[1].game_ready_cannon_shoot
	await get_tree().create_timer(delay_before_shoot).timeout
	print("[Canon] shoot")
	shoot.emit()
	reload_progress = 0

func _find_workers(recruitment_range: float) -> Agent:
	if available_slots.size():
		var nearest_agent: Agent = null
		var nearest_distance: float = 0
		for agent: Agent in get_tree().get_nodes_in_group(&"Versaillais"):
			if agent.canon_slot: continue
			var distance: float = agent.global_position.distance_squared_to(global_position)
			if distance > recruitment_range: continue
			if not nearest_agent or distance < nearest_distance:
				nearest_agent = agent
				nearest_distance = distance
		if nearest_agent: return nearest_agent
	return null

func is_slot_available() -> bool: return available_slots.size()

func _take_slot(agent: Agent) -> Marker3D:
	var slot: Marker3D = available_slots.pop_front()
	holded_slots.push_back(slot)
	if move_speeds[holded_slots.size()]: start_move.emit()
	if not agent.died.is_connected(_restore): agent.died.connect(_restore.bind(slot))
	else: print(agent.name, "is already conected")
	if not agent.died.is_connected(_on_worker_died): agent.died.connect(_on_worker_died.bind(agent))
	return slot

func _restore(slot: Marker3D) -> void:
	holded_slots.erase(slot)
	available_slots.push_back(slot)
	if not move_speeds[holded_slots.size()]: stop_move.emit()

func _create_workers() -> void:
	for i in range(2):
		var new_worker: Agent = WORKER_PREFAB.instantiate()
		add_child(new_worker)
		new_worker.global_transform = global_transform
		new_worker.global_position += global_basis.z * 4 + global_basis.x * i

func _on_worker_died(worker: Agent) -> void:
	workers.erase(worker)
	workers_updated.emit(workers)


func move_to_second_path() -> void:
	reparent(second_path)


enum State { NONE, MOVING, RELOADING }
