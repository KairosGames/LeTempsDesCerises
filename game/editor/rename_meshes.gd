@tool
extends EditorScript

func _run() -> void:
	var selection: Array[Node] = EditorInterface.get_selection().get_selected_nodes()
	if selection.size() != 1: push_error("must be one node in selection"); return
	
	var root: Node = selection[0]
	
	var children: Array[Node] = root.get_children()
	
	for child: Node in children:
		if child is not MeshInstance3D: continue
		var mesh_instance: MeshInstance3D = child
		var mesh: Mesh = mesh_instance.mesh
		var name: String = mesh.resource_path.get_file().get_basename().to_pascal_case()
		mesh_instance.name = name
