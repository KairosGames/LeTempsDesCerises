@tool
extends EditorPlugin

const NAME: String = "MeshCombiner3D"
const BASE_TYPE: String = "MultiMeshInstance3D"
const SCRIPT: Script = preload("mesh_combiner_3d.gd")
const ICON: Texture2D = preload("icon.svg")

func _get_plugin_name() -> String: return NAME

func _enter_tree() -> void: add_custom_type(NAME, BASE_TYPE, SCRIPT, ICON)

func _exit_tree() -> void: remove_custom_type(NAME)
