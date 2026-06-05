@tool
extends EditorPlugin

const ShootTargetGizmo = preload("uid://bu5y1tgcpuo4c")
var _gizmo: ShootTargetGizmo = ShootTargetGizmo.new()

func _enter_tree() -> void:
	add_node_3d_gizmo_plugin(_gizmo)

func _exit_tree() -> void:
	remove_node_3d_gizmo_plugin(_gizmo)
