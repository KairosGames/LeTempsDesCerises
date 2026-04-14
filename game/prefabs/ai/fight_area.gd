@tool
class_name FightArea extends Marker3D

@export var size: float = 30:
	set(value):
		size = value
		_gizmo.radius = value / 2.0
		_gizmo.height = value

@export_group("Debug")
@export var debug_editor_only: bool = true:
	set(value): debug_editor_only = value; update_debug()
@export var debug_enable: bool = true:
	set(value): debug_enable = value; update_debug()

var _gizmo: SphereMesh = create_gizmo()
var _gizmo_handler: MeshInstance3D = null

func _enter_tree() -> void:
	if GameManager.active_barricade:
		push_error("There must be only one FightArea !")
		return
	GameManager.active_barricade = self
	update_debug()


func update_debug() -> void:
	var should_debug: bool = debug_enable and (not debug_editor_only or Engine.is_editor_hint())
	if not _gizmo_handler and should_debug:
		_gizmo_handler = MeshInstance3D.new()
		_gizmo_handler.mesh = _gizmo
		add_child(_gizmo_handler, false, Node.INTERNAL_MODE_FRONT)
	if _gizmo_handler and not should_debug:
		_gizmo_handler.queue_free()
		_gizmo_handler = null


func create_gizmo() -> SphereMesh:
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = Color(Color.RED, 0.2)
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	var mesh: SphereMesh = SphereMesh.new()
	mesh.radius = size / 2.0
	mesh.height = size
	mesh.material = material
	return mesh
