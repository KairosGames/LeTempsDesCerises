@tool
class_name MeshCombiner3D extends MultiMeshInstance3D

@export_tool_button("Merge") var merge: Callable = _merge
@export_tool_button("Split") var split: Callable = _split

func _init() -> void: _ensure_multimesh()

func _ensure_multimesh():
	if multimesh == null:
		multimesh = MultiMesh.new()
		multimesh.transform_format = MultiMesh.TRANSFORM_3D

# FIXME conflict with export_tool_button
#func _validate_property(property: Dictionary) -> void:
	#match property.name:
		#"merge" when not _can_merge(): property.usage = PROPERTY_USAGE_NO_EDITOR
		#"split" when not _can_split(): property.usage = PROPERTY_USAGE_NO_EDITOR

func _get_configuration_warnings():
	var warnings: PackedStringArray
	if multimesh.mesh == null:
		warnings.append("The multimesh has no mesh resource.")
	if not multimesh.instance_count:
		warnings.append("The multimesh has no instances (Consider to Merge).")
	return warnings

func _can_split() -> bool:
	return multimesh.mesh and multimesh.instance_count

func _can_merge() -> bool:
	if multimesh.instance_count > 0: return false
	if not get_child_count(): return false
	var first_child: Node = get_child(0)
	if first_child is not MeshInstance3D: return false
	if not (first_child as MeshInstance3D).mesh: return false
	return true

func _merge() -> void:
	if not _can_merge():
		printerr("Cannot Merge")
		return

	var instances: Array = get_children()
	var mesh: Mesh = multimesh.mesh
	if not mesh:
		for instance: MeshInstance3D in instances:
			if instance.mesh: mesh = instance.mesh
			break
	var count: int = instances.size()
	multimesh.instance_count = 0
	multimesh.transform_format = MultiMesh.TRANSFORM_3D
	multimesh.instance_count = count
	multimesh.mesh = mesh
	for index: int in range(count):
		var child: MeshInstance3D = instances[index]
		multimesh.set_instance_transform(index, child.transform)
		child.queue_free()
	notify_property_list_changed()
	EditorInterface.mark_scene_as_unsaved()

func _split():
	if not _can_split():
		printerr("Cannot Split")
		return

	for index: int in multimesh.instance_count:
		var instance: MeshInstance3D = MeshInstance3D.new()
		add_child(instance)
		instance.owner = owner
		instance.transform = multimesh.get_instance_transform(index)
		instance.mesh = multimesh.mesh
		instance.name = instance.mesh.resource_path.get_file().get_basename().to_pascal_case()

	multimesh.instance_count = 0
	multimesh.transform_format = MultiMesh.TRANSFORM_3D
	multimesh.mesh = null
	notify_property_list_changed()
	EditorInterface.mark_scene_as_unsaved()
