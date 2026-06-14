class_name BakeBarricade extends Node3D

@export var static_bodies: Array[StaticBody3D]

func _ready() -> void:
	visible = false
	for body: StaticBody3D in static_bodies: body.process_mode = Node.PROCESS_MODE_DISABLED
