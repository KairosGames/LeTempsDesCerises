@tool
extends MeshInstance3D

@export var texture : Texture2D :
	set(new_value):
		texture = new_value
		if Engine.is_editor_hint():
			resize_mesh()
			apply_texture()

@export_range(0,1,0.01) var ratio : float = 0.05 :
	set(new_value) :
		ratio = new_value
		if Engine.is_editor_hint():
			resize_mesh()

func resize_mesh() :
	mesh.size = texture.get_size() * (ratio / 100)

func apply_texture():
	mesh.material.albedo_texture = texture
	
