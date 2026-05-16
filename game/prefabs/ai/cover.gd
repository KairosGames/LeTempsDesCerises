@tool
class_name Cover extends Marker3D

@export var type: Type = Type.COVER
@export var next_covers: Array[Cover] = []
@export var colors: Dictionary[Type, Color] = {
	Type.COVER: Color.GREEN_YELLOW,
	Type.TRANSITORY: Color.ORANGE,
	Type.SPAWNER: Color.CYAN,
}
@export var enabled: bool = true

var holder: Agent = null

const LINE_SIZE: float = 0.1
const MOTION_WIDTH: float = 0.1
const EDITOR_ONLY: bool = true
enum Type { COVER, TRANSITORY, SPAWNER }

var _color: Color
var _lines: MultiMeshInstance3D
var _motions: MultiMeshInstance3D
var _point: MeshInstance3D
var _line_material: StandardMaterial3D = StandardMaterial3D.new()
var _motion_material: StandardMaterial3D = StandardMaterial3D.new()
var _point_material: StandardMaterial3D = StandardMaterial3D.new()

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray
	if next_covers.has(self): warnings.append("Should not be linked to self")
	if not colors.has(Type.COVER): warnings.append("Color for Type.COVER not defined")
	if not colors.has(Type.TRANSITORY): warnings.append("Color for Type.TRANSITORY not defined")
	if not colors.has(Type.SPAWNER): warnings.append("Color for Type.SPAWNER not defined")
	return warnings

func _ready() -> void:
	if is_gizmo_enabled():
		_init_name()
		_init_point()
		_init_lines()
		_init_motions()

func _process(_delta: float) -> void: _update_gizmos()

func _init_name() -> void:
	var label: Label3D = Label3D.new()
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.text = name
	label.position = Vector3(0, 0.5, 0)
	add_child(label, false, Node.INTERNAL_MODE_BACK)
	renamed.connect(func() -> void: label.set_text(self.name) )

func _init_lines() -> void:
	_lines = MultiMeshInstance3D.new()
	_lines.top_level = true

	_line_material.albedo_color = Color(Color.WHITE, 0.2)
	_line_material.vertex_color_use_as_albedo = true
	_line_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_line_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED

	var line_mesh: BoxMesh = BoxMesh.new()
	line_mesh.material = _line_material

	_lines.multimesh = MultiMesh.new()
	_lines.multimesh.transform_format = MultiMesh.TRANSFORM_3D
	_lines.multimesh.use_colors = true
	_lines.multimesh.mesh = line_mesh

	add_child(_lines, false, Node.INTERNAL_MODE_FRONT)

func _init_motions() -> void:
	_motions = MultiMeshInstance3D.new()
	_motions.top_level = true

	_motion_material.albedo_color = Color(Color.WHITE, 0.7)
	_motion_material.vertex_color_use_as_albedo = true
	_motion_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_motion_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED

	var motion_mesh: SphereMesh = SphereMesh.new()
	motion_mesh.material = _motion_material
	motion_mesh.radius = 0.2
	motion_mesh.height = motion_mesh.radius * 2
	motion_mesh.rings = 4
	motion_mesh.radial_segments = motion_mesh.rings * 2

	_motions.multimesh = MultiMesh.new()
	_motions.multimesh.transform_format = MultiMesh.TRANSFORM_3D
	_motions.multimesh.use_colors = true
	_motions.multimesh.mesh = motion_mesh

	add_child(_motions, false, Node.INTERNAL_MODE_FRONT)

func _init_point() -> void:
	_point = MeshInstance3D.new()

	_point_material.albedo_color = Color(_color, 0.9)
	_point_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_point_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED

	var mesh: BoxMesh = BoxMesh.new()
	mesh.material = _point_material
	mesh.size = Vector3.ONE * 0.3

	_point.mesh = mesh

	add_child(_point, false, Node.INTERNAL_MODE_FRONT)

func _update_gizmos() -> void:
	if is_gizmo_enabled():
		_update_color()
		_update_lines()
		_update_motions()

func _update_color() -> void:
	if _color != colors[type]:
		_color = colors[type]
		_point_material.albedo_color = Color(_color if enabled else Color.BLACK, 0.9)

func _update_lines() -> void:
	if not _lines or not _lines.multimesh: return

	if _lines.multimesh.instance_count != next_covers.size():
		_lines.multimesh.instance_count = next_covers.size()

	for i: int in range(next_covers.size()):
		var next_cover: Cover = next_covers[i]
		if not next_cover:
			_lines.multimesh.set_instance_transform(i, Transform3D(Basis.from_scale(Vector3.ZERO), Vector3.ZERO))
			break
		var color: Color = colors[Type.TRANSITORY] if next_cover.type == Type.TRANSITORY else colors[type]
		if not next_cover.enabled: color = Color.BLACK
		var line_position: Vector3 = (global_position + next_cover.global_position) / 2.0
		var line_length: float = global_position.distance_to(next_cover.global_position)
		var line_scale: Vector3 = Vector3(LINE_SIZE, LINE_SIZE, line_length)
		var line_basis: Basis = Basis.looking_at(global_position.direction_to(next_cover.global_position)).scaled_local(line_scale)
		var line_transform: Transform3D = Transform3D.IDENTITY
		line_transform.origin = line_position
		line_transform.basis = line_basis
		_lines.multimesh.set_instance_color(i, color)
		_lines.multimesh.set_instance_transform(i, line_transform)

func _update_motions() -> void:
	if not _motions or not _motions.multimesh: return

	var t: float = (Time.get_ticks_msec() / 1000.0)
	var motion_progress: float = t - floorf(t)

	if _motions.multimesh.instance_count != next_covers.size():
		_motions.multimesh.instance_count = next_covers.size()

	for i: int in range(next_covers.size()):
		var next_cover: Cover = next_covers[i]
		if not next_cover:
			_motions.multimesh.set_instance_transform(i, Transform3D(Basis.from_scale(Vector3.ZERO), Vector3.ZERO))
			break
		var color: Color = colors[Type.TRANSITORY] if next_cover.type == Type.TRANSITORY else colors[type]
		if not next_cover.enabled: color = Color.BLACK
		var motion_position: Vector3 = global_position.lerp(next_cover.global_position, motion_progress)
		var motion_transform: Transform3D = Transform3D.IDENTITY
		motion_transform.origin = motion_position
		_motions.multimesh.set_instance_color(i, color)
		_motions.multimesh.set_instance_transform(i, motion_transform)

func is_gizmo_enabled() -> bool:
	return Engine.is_editor_hint() or not EDITOR_ONLY
