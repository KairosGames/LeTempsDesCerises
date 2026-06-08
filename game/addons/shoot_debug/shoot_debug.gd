extends MultiMeshInstance3D

const POOL_SIZE: int = 100
const DEBUG_LINE: BoxMesh = preload("uid://dlk3762ys1jgb")

var _open: Array[int] = []

func _ready() -> void:
	multimesh = MultiMesh.new()
	multimesh.use_colors = true
	multimesh.mesh = DEBUG_LINE
	multimesh.transform_format = MultiMesh.TRANSFORM_3D
	multimesh.instance_count = POOL_SIZE
	for i: int in range(POOL_SIZE):
		_open.append(i)

func add_debug(origin: Vector3, direction: Vector3, color: Color, is_player: bool, duration: float = 3.0, distance: float = 100.0) -> void:
	if not ProjectSettings.get_setting("addons/shoot_debug/enabled", false): return
	if not _open.size(): printerr("pool is not big enough"); return
	var index: int = _open.pop_front()
	var line_basis: Basis = Basis.from_euler(direction)
	var line_transform: Transform3D = Transform3D(line_basis, origin + (1 if is_player else -1) * line_basis.z * distance / 2.0 )
	multimesh.set_instance_transform(index, line_transform)
	multimesh.set_instance_color(index, Color(color, 1.0))
	var tween: Tween = create_tween()
	tween.tween_method(
		func(new_color: Color) -> void: multimesh.set_instance_color(index, new_color),
		Color(color, 1),
		Color(color, 0),
		duration
	)
	tween.tween_callback(func(): _open.push_front(index))
