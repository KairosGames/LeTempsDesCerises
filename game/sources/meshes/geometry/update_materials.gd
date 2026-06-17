@tool
extends EditorScript

const MESH_DIR: String = "res://sources/meshes/geometry/meshes/"
const MATERIAL_DIR: String = "res://sources/meshes/geometry/materials/"
const OUTPUT_DIR: String = "res://prefabs/geometry/"

# material -> override
const MATERIAL_OVERRIDES: Dictionary[StringName, StringName] = {
	"bricks": "concrete",
	"brick_b": "concrete",
	"wood_a": "plank",
	"wood_b": "plank",
}
# Dictionary[StringName, Array[Dictionary]]
const MESH_VARIANTS: Dictionary[StringName, Array] = {
	"wall_a": [
		{
			"variant_name": "wall_a_long_brick",
			"material_overrides": { "wall": "long_brick" },
		}
	]
}

func _run() -> void:
	# Collect materials
	var materials: Dictionary[String, Material]
	for material_file: String in DirAccess.get_files_at(MATERIAL_DIR):
		var path: String = MATERIAL_DIR + material_file
		var material: Material = load(path)
		if material: materials[material_file.get_basename()] = material

	# Generate Mesh Variant
	for mesh_file: String in DirAccess.get_files_at(MESH_DIR):
		if not mesh_file.ends_with(".obj"): continue
		var path: String = MESH_DIR + mesh_file
		var name: String = mesh_file.get_basename()
		var mesh: ArrayMesh = load(path)
		if not mesh: 
			push_error("Failed to load %s at %s" % [name, path])
			continue
		
		_create_variant(mesh, materials, MATERIAL_OVERRIDES, name)
		
		if MESH_VARIANTS.has(name):
			for variant: Dictionary in MESH_VARIANTS[name]:
				var variant_name: String = variant["variant_name"]
				var overrides: Dictionary = variant["material_overrides"]
				_create_variant(mesh, materials, overrides, variant_name)
	
func _create_variant(
	original_mesh: ArrayMesh,
	materials: Dictionary[String, Material],
	material_overrides: Dictionary,
	name: String) -> void:
	var mesh: ArrayMesh = original_mesh.duplicate() # deep?
	for index: int in range(mesh.get_surface_count()):
		var surface_name: String = mesh.surface_get_name(index)
		if material_overrides.has(surface_name): surface_name = material_overrides[surface_name]
		if materials.has(surface_name):
			mesh.surface_set_material(index, materials[surface_name])
		else:
			push_warning("material ",surface_name," not available")
	var output_path: String = OUTPUT_DIR + name + ".tres"
	ResourceSaver.save(mesh, output_path)
