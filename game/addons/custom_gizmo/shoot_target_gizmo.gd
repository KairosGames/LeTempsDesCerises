@tool 
extends EditorNode3DGizmoPlugin

const CONTAINER_NAME: StringName = &"ShootTargets"
const SIZE: float = 0.1
const MESH: Mesh = preload("uid://d2vgcib2fxm6q")

func _get_gizmo_name() -> String: return "ShootTargets"

func _has_gizmo(node: Node): 
	var parent: Node = node.get_parent()
	if is_instance_valid(parent):
		return parent.name == CONTAINER_NAME and node is Marker3D

func _redraw(gizmo: EditorNode3DGizmo):
	gizmo.clear()
	gizmo.add_mesh(MESH, null)
