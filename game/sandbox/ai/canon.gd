class_name Canon extends PathFollow3D

static var singleton: Canon

signal shoot

@export_custom(PROPERTY_HINT_NONE,"suffix: m/s") var speed: float = 1
@export_custom(PROPERTY_HINT_NONE,"suffix: s") var shoot_delay: float = 5

@onready var slots: Array[Marker3D] = [$AnimatableBody3D/Slot0, $AnimatableBody3D/Slot1, $AnimatableBody3D/Slot2]

var _last_shoot_time: float

func _physics_process(delta: float) -> void:
	var pusher_count: float = 0
	for slot in slots: if slot.get_child_count(): pusher_count += 1
	progress += speed * (pusher_count / slots.size()) * delta
	if progress_ratio == 1 and (Time.get_ticks_msec() - _last_shoot_time) > shoot_delay * 1000:
		print("[Canon] shoot")
		shoot.emit()

func _ready() -> void: singleton = self
