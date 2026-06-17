@tool
extends EditorScript

const OCULDER_CONTAINER_NAME: String = "Occluders"

func _run() -> void:
	var selection: Array[Node] = EditorInterface.get_selection().get_selected_nodes()
	if selection.size() > 1:
		push_error("must be only one node in slection for occlusion generation")
		return
	if selection[0] is not StaticBody3D:
		push_error("selected node must be a StaticBody3D")
		return
	var body: StaticBody3D = selection[0]
	var parent: Node = body.get_parent()
	var occluder_container: Node3D = parent.get_node_or_null(OCULDER_CONTAINER_NAME)
	if not occluder_container:
		occluder_container = Node3D.new()
		parent.add_child(occluder_container)
		occluder_container.name = OCULDER_CONTAINER_NAME
		occluder_container.owner = body.owner
	for collider: CollisionShape3D in body.get_children():
		var occluder_instance: OccluderInstance3D = OccluderInstance3D.new()
		occluder_container.add_child(occluder_instance)
		occluder_instance.owner = occluder_container.owner
		var occluder: BoxOccluder3D = BoxOccluder3D.new()
		occluder_instance.global_transform = collider.global_transform
		occluder.size = (collider.shape as BoxShape3D).size
		occluder_instance.occluder = occluder
