@tool
class_name Cover extends Marker3D

# TODO cover signal

#TODO? @export var inherit_color: bool = false
@export var color: Color = Color.GREEN_YELLOW
@export var next_covers: Array[Cover] = []

const LINE_WIDTH: float = 0.1

var _lines: MultiMeshInstance3D
var _point: MeshInstance3D

func _ready() -> void:
	if Engine.is_editor_hint():
		_init_point()
		_init_lines()
		
func _init_lines() -> void:
	_lines = MultiMeshInstance3D.new()
	_lines.top_level = true
	var mesh: BoxMesh = BoxMesh.new()
	_lines.multimesh = MultiMesh.new()
	_lines.multimesh.use_colors = true
	_lines.multimesh.transform_format = MultiMesh.TRANSFORM_3D
	_lines.multimesh.mesh = mesh
	add_child(_lines, false, Node.INTERNAL_MODE_FRONT)

func _init_point() -> void:
	_point = MeshInstance3D.new()
	var mesh: BoxMesh = BoxMesh.new()
	mesh.size = Vector3.ONE * 0.3
	# TODO color
	_point.mesh = mesh
	add_child(_point, false, Node.INTERNAL_MODE_FRONT)

func _enter_tree() -> void: if not Engine.is_editor_hint(): CoverManager.register(self)
	
func _exit_tree() -> void: if not Engine.is_editor_hint(): CoverManager.unregister(self)

func _process(_delta: float) -> void: _update_debug()
	
func _update_debug() -> void:
	if not Engine.is_editor_hint(): return
	if not _lines or not _lines.multimesh: return
	
	_lines.multimesh.instance_count = next_covers.size()
	for i: int in range(next_covers.size()):
		var cover: Cover = next_covers[i]
		if not cover: 
			_lines.multimesh.set_instance_transform(i, Transform3D(Basis.from_scale(Vector3.ZERO), Vector3.ZERO))
			
		var line_position: Vector3 = (global_position + cover.global_position) / 2.0
		var length: float = global_position.distance_to(cover.global_position)
		var line_scale: Vector3 = Vector3(LINE_WIDTH, LINE_WIDTH, length)
		var line_rotation: Vector3 = Vector3.ZERO #global_position.angle_to(cover.global_position)
		var line_basis: Basis = Basis.from_euler(line_rotation) * Basis.from_scale(line_scale)
		_lines.multimesh.set_instance_color(i, color) # TODO check if mesh need shader
		var line_transform: Transform3D = Transform3D.IDENTITY
		line_transform.origin = line_position
		line_transform.basis = line_basis
		_lines.multimesh.set_instance_transform(i, line_transform)
