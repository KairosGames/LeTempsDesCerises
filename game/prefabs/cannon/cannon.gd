class_name Canon extends PathFollow3D

static var singleton: Canon

signal start_move
signal stop_move
signal start_reload
signal reloaded
signal shoot
signal workers_updated(workers: Array[Agent])
signal move_progress_changed(percent: float)
signal reload_progress_changed(percent: float)
signal is_ready_to_shoot_in_cinematic

@onready var objective_point: Marker3D = %ObjectivePoint
@onready var second_path: Path3D = %Path3DCannon2
@onready var animation: AnimationTree = $AnimationTree
@onready var cannon_shoot_effect: ParticlesPlayer = %CannonShootEffect

@export_custom(PROPERTY_HINT_NONE,"suffix: m/s") var move_speeds: Array[float] = [0, 0, 0.5, 1]
@export_custom(PROPERTY_HINT_NONE,"suffix: s") var reload_duration: Array[float] = [0, 15, 10, 5]
@export_custom(PROPERTY_HINT_NONE,"suffix: s") var patience: float = 5.0
@export_custom(PROPERTY_HINT_NONE,"suffix: s") var delay_before_shoot: float = 2.0
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
var _is_moving: bool = false

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
		var recruitment_range: float = max_recruitment_range * recruitment_range_boost if _time_without_worker > patience else max_recruitment_range
		var new_worker: Agent = _find_workers(recruitment_range)
		if new_worker:
			var slot: Marker3D = _take_slot(new_worker)
			new_worker.canon_slot = slot
			workers.append(new_worker)
			workers_updated.emit(workers)
			_time_without_worker = 0
		else: _time_without_worker += delta


	var worker_count: int = active_worker_count()
	
	match _state:
		State.MOVING:
			var move_speed: float = move_speeds[worker_count]
			animation.set("parameters/MoveSpeed/scale", move_speed)
			_is_moving = move_speed > 0.0
			progress += move_speed * delta
			move_progress = progress_ratio
			if move_progress == 1.0:
				_state = State.RELOADING
				_is_moving = false
			for worker: Agent in workers:
				worker.is_reloading_canon = false
				worker.is_moving = _is_moving
		State.RELOADING:
			animation.set("parameters/MoveSpeed/scale", 0)
			_is_moving = false
			for worker: Agent in workers:
				worker.is_reloading_canon = true
				worker.is_moving = false
			if reload_progress < 1.0:
				if reload_progress == 0.0: start_reload.emit()
				if worker_count: reload_progress += delta / reload_duration[worker_count]
				if reload_progress == 1.0:
					#stop_reload.emit()
					reloaded.emit()
					_shoot()

func _shoot() -> void:
	if _is_first_shoot:
		_is_first_shoot = false
		reload_progress = 0
		await (GameManager.instance.all_states[1] as GameState01).game_ready_cannon_shoot
		is_ready_to_shoot_in_cinematic.emit()
	await get_tree().create_timer(delay_before_shoot).timeout
	shoot.emit()
	animation.set("parameters/Shoot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	play_smoke_effect()
	cannon_shoot_effect.play_effect()
	
	reload_progress = 0

func play_smoke_effect() -> void:
	if not EffectsManager.instance: return
	var eff: EffectsManager.EffectType = EffectsManager.EffectType.CannonSmoke
	var pos: Vector3 = cannon_shoot_effect.global_position
	var rot: Vector3 = cannon_shoot_effect.global_rotation
	EffectsManager.instance.play_effect(eff, pos, rot)

func _find_workers(recruitment_range: float) -> Agent:
	if available_slots.size():
		var nearest_agent: Agent = null
		var nearest_distance: float = 0
		for agent: Agent in get_tree().get_nodes_in_group(&"Versaillais"):
			if agent.canon_slot: continue
			if not agent.is_alive: continue
			var distance: float = agent.global_position.distance_squared_to(global_position)
			if distance > recruitment_range * recruitment_range: continue
			if not nearest_agent or distance < nearest_distance:
				nearest_agent = agent
				nearest_distance = distance
		if nearest_agent: return nearest_agent
	return null

func is_slot_available() -> bool: return available_slots.size()

func active_worker_count() -> int:
	var count: int = 0
	for worker: Agent in workers: if worker.is_working_on_cannon and worker.is_alive: count += 1
	return count

func _take_slot(agent: Agent) -> Marker3D:
	var slot: Marker3D = available_slots.pop_front()
	holded_slots.push_back(slot)
	if move_speeds[holded_slots.size()]: 
		start_move.emit()
	agent.dying.connect(_restore.bind(slot).bind(agent))
	agent.dying.connect(_on_worker_died.bind(agent))
	return slot

func _restore(agent: Agent ,slot: Marker3D) -> void:
	agent.top_level = true
	holded_slots.erase(slot)
	available_slots.push_back(slot)
	if not move_speeds[holded_slots.size()]: 
		stop_move.emit()

func _create_workers(n: int = 2) -> void:
	for i: int in range(n):
		var new_worker: Agent = WORKER_PREFAB.instantiate()
		add_child(new_worker)
		new_worker.global_transform = global_transform
		new_worker.global_position += global_basis.z * 4 + global_basis.x * i

func _on_worker_died(worker: Agent) -> void:
	workers.erase(worker)
	workers_updated.emit(workers)
	var move_speed: float = move_speeds[active_worker_count()]
	if not move_speed: _is_moving = false


func move_to_second_path() -> void:
	reparent(second_path)
	_state = State.MOVING
	progress_ratio = 0.0
	move_progress = 0.0


enum State { NONE, MOVING, RELOADING }
