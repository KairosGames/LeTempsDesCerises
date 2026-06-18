@tool
extends EditorScript

const MESH_DIR: String = "res://sources/meshes/geometry/meshes/"
const OUTPUT_DIR: String = "res://prefabs/geometry/"

# Dictionary[StringName, Array[Dictionary]]
const MESH_VARIANTS: Dictionary[StringName, Array] = {
	"wall_a": ["wall_a_long_brick"]
}

func _run() -> void:
	# Generate Mesh Variant
	for mesh_file: String in DirAccess.get_files_at(MESH_DIR):
		if not mesh_file.ends_with(".obj"): continue
		var path: String = MESH_DIR + mesh_file
		var name: String = mesh_file.get_basename()
		var mesh: ArrayMesh = load(path)
		if not mesh: 
			push_error("Failed to load %s at %s" % [name, path])
			continue
		
		_create_variant(mesh, name, name)
		
		if MESH_VARIANTS.has(name):
			for variant_name: String in MESH_VARIANTS[name]:
				_create_variant(mesh, variant_name, name)
	
func _create_variant(original_mesh: ArrayMesh, name: String, original_name: String) -> void:
	var mesh: ArrayMesh = original_mesh.duplicate() # deep?
	var output_path: String = OUTPUT_DIR + name + ".tres"
	var existing: ArrayMesh = load(output_path)
	for index: int in range(mesh.get_surface_count()):
		var surface_name: String = mesh.surface_get_name(index)
		if existing and existing.surface_get_name(index) == surface_name:
			mesh.surface_set_material(index, existing.surface_get_material(index))
		else:
			mesh.surface_set_material(index, null)
			push_warning("material ",surface_name," not available")
	print("create %s variation of %s" % [name, original_name])
	ResourceSaver.save(mesh, output_path)
