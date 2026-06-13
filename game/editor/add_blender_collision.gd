@tool
extends EditorScenePostImport

func _post_import(scene: Node) -> Object:
	if scene != null:
		for i in range(scene.get_child_count() -1, -1, -1):
			var child: Node = scene.get_child(i)
			if child.name.contains("-col") and child is Node3D:
				scene.remove_child(child)
				var collision_shape: CollisionShape3D = CollisionShape3D.new()
				collision_shape.rotation = child.rotation
				collision_shape.position = child.position
				var shape: BoxShape3D = BoxShape3D.new()
				shape.size = child.scale * 2
				collision_shape.shape = shape
				scene.add_child(collision_shape)
				collision_shape.owner = child.owner
	return scene
