@tool
extends EditorScript

const MESH_DIR: String = "res://sources/meshes/geometry/meshes/"
const MATERIAL_DIR: String = "res://sources/meshes/geometry/materials/"
const OUTPUT_DIR: String = "res://prefabs/geometry/"

func _run() -> void:
	var materials: Dictionary[String, Material]
	for material_file in DirAccess.get_files_at(MATERIAL_DIR):
		var path: String = MATERIAL_DIR + material_file
		var material: Material = load(path)
		if material:
			materials[material_file.get_basename()] = material

	for mesh_file in DirAccess.get_files_at(MESH_DIR):
		if not mesh_file.ends_with(".obj"): continue
		var path: String = MESH_DIR + mesh_file
		var name: String = mesh_file.get_basename()
		var mesh: ArrayMesh = load(path)
		if not mesh: continue
		mesh = mesh.duplicate() # deep?
		for index: int in range(mesh.get_surface_count()):
			var surface_name: String = mesh.surface_get_name(index)
			if materials.has(surface_name):
				mesh.surface_set_material(index, materials[surface_name])
			else:
				push_warning("material ",surface_name," not available")
		var output_path: String = OUTPUT_DIR + name + ".tres"
		ResourceSaver.save(mesh, output_path)
