class_name ShootDebug extends MultiMeshInstance3D

static var instance: ShootDebug

const POOL_SIZE: int = 100
const DEBUG_LINE: BoxMesh = preload("uid://dlk3762ys1jgb")

var _open: Array[int] = []

func _ready() -> void:
	instance = self
	multimesh = MultiMesh.new()
	multimesh.use_colors = true
	multimesh.use_custom_data = true
	multimesh.mesh = DEBUG_LINE
	multimesh.transform_format = MultiMesh.TRANSFORM_3D
	multimesh.instance_count = POOL_SIZE
	for i: int in range(POOL_SIZE):
		_open.append(i)

func add_debug(origin: Vector3, direction: Vector3, color: Color, is_player: bool, duration: float = 3.0, distance: float = 100.0) -> void:
	if not _open.size(): printerr("pool is not big enough"); return

	var index: int = _open.pop_front()

	var line_basis: Basis = Basis.from_euler(direction)
	multimesh.set_instance_transform(index, Transform3D(line_basis, origin + (1 if is_player else -1) * line_basis.z * distance / 2.0 ))
	multimesh.set_instance_color(index, Color(color, 1.0))
	multimesh.set_instance_custom_data(index, Color(Time.get_ticks_msec() / 1000.0, duration,0,0))
	_process_line(index, duration)

func _process_line(index: int, duration: float) -> void:
	await get_tree().create_timer(duration).timeout
	_open.push_front(index)

func tween_line(opacity: float, index: int) -> void:
	multimesh.set_instance_color(index, Color(multimesh.get_instance_color(index), opacity))
