class_name ShootDebug extends MultiMeshInstance3D

static var instance: ShootDebug

const POOL_SIZE: int = 100
const DEBUG_LINE: BoxMesh = preload("uid://dlk3762ys1jgb")

var _open: Array[int] = []
var _close: Array[int] = []

func _ready() -> void:
	instance = self
	multimesh.instance_count = POOL_SIZE
	multimesh.mesh = DEBUG_LINE
	for i: int in range(POOL_SIZE): 
		_open.append(i)
		multimesh.set_instance_color(i, Color.RED)
		multimesh.set_instance_transform(i, Transform3D.IDENTITY)

func add_debug(origin: Vector3, direction: Vector3, color: Color, duration: float = 10.0, distance: float = 100.0) -> void:
	if not _open.size(): printerr("pool is not big enough"); return
	
	var index: int = _open.pop_front()
	_close.append(index)
	
	var line_basis: Basis = Basis.from_euler(direction)
	multimesh.set_instance_transform(index, Transform3D(line_basis, origin + line_basis.z * distance / 2.0 ))
	multimesh.set_instance_color(index, color)
	_process_line(index, duration)

func _process_line(index: int, duration: float) -> void:
	var tween: Tween = create_tween()
	await tween.tween_method(tween_line.bind(index), 1.0, 0.0, duration).finished
	_close.erase(index)
	_open.push_front(index)
	
func tween_line(opacity: float, index: int) -> void:
	multimesh.set_instance_color(index, Color(multimesh.get_instance_color(index), opacity))
