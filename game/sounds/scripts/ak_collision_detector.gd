extends Node

@onready var geometry : PackedScene = preload("res://sounds/prefabs/ak_geometry_preset.tscn")

func _ready() -> void:
	for child : Node in get_children():
		for sub_child : Node3D in child.get_children():
			print(sub_child.name)
			if sub_child.is_class("MeshInstance3D"):
				print(child.name)
				var new_geo := geometry.instantiate()
				sub_child.add_child(new_geo)
				return
