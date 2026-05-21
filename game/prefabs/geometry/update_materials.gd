@tool
extends EditorScript

const MESH_DIR: String = "res://prefabs/geometry/meshes/"
const MATERIAL_DIR: String = "res://prefabs/geometry/materials/"

func _run() -> void:
	var materials: Dictionary[String, Material]
	var materials_files: PackedStringArray = DirAccess.get_files_at(MATERIAL_DIR)
	for material_file in materials_files:
		var path: String = MATERIAL_DIR + material_file
		var material: Material = load(path)
		if material: 
			materials[material_file.get_basename()] = material
			
	var meshes_files: PackedStringArray = DirAccess.get_files_at(MESH_DIR)
	for mesh_file in meshes_files:
		if mesh_file.ends_with(".obj"):
			var path: String = MESH_DIR + mesh_file
			var mesh: ArrayMesh = load(path)
			for index: int in range(mesh.get_surface_count()):
				var surface_name: String = mesh.surface_get_name(index)
				print(surface_name)
				if materials.has(surface_name):
					mesh.surface_set_material(index, materials[surface_name])
			ResourceSaver.save(mesh, path)
