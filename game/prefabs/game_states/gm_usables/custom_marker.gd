class_name CustomMaker extends Marker3D

@onready var mesh_marker: MeshInstance3D = %MeshMarker

func _ready() -> void:
	mesh_marker.visible = false
