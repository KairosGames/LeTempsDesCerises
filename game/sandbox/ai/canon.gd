class_name Canon extends PathFollow3D

static var singleton: Canon

signal shoot

@export_custom(PROPERTY_HINT_NONE,"suffix: m/s") var speed: float = 1
@export_custom(PROPERTY_HINT_NONE,"suffix: s") var shoot_delay: float = 5

var available_slots: Array[Marker3D] = []
var holded_slots: Array[Marker3D] = []

@onready var _slots: Array[Marker3D] = [$AnimatableBody3D/Slot0, $AnimatableBody3D/Slot1, $AnimatableBody3D/Slot2]

var _last_shoot_time: float

func _physics_process(delta: float) -> void:
	progress += speed * (holded_slots.size() / float(_slots.size())) * delta
	if progress_ratio == 1 and (Time.get_ticks_msec() - _last_shoot_time) > shoot_delay * 1000:
		print("[Canon] shoot")
		shoot.emit()

func _ready() -> void: 
	singleton = self
	available_slots = _slots.duplicate()

func is_slot_available() -> bool: return available_slots.size()

func take_slot(agent: Agent) -> Marker3D:
	var slot: Marker3D = available_slots.pop_front()
	holded_slots.push_back(slot)
	agent.died.connect(_restore.bind(slot))
	return slot

func _restore(slot: Marker3D) -> void:
	available_slots.push_back(slot)
