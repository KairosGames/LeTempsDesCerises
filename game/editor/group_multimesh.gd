@tool
extends EditorScript

func _run() -> void:
	var selection: Array[Node] = EditorInterface.get_selection().get_selected_nodes()
	if selection.size() != 1: push_error("must be one node in selection"); return
	
	var root: Node = selection[0]
	
	for child: Node in root.get_children():
		if child is not MeshInstance3D: continue
		var mesh_instance: MeshInstance3D = child
		var mesh: Mesh = mesh_instance.mesh
		var name: String = mesh.resource_path.get_file().get_basename().to_pascal_case()
		var group: Node = root.get_node_or_null(name)
		if group is MeshInstance3D:
			group.name += str(randi_range(0, 10000))
			group = null
		if not group: 
			var new_group: Node3D = Node3D.new()
			new_group.name = name
			root.add_child(new_group)
			group = new_group
		
		mesh_instance.reparent(group)
