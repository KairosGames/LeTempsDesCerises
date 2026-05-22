class_name DeathPetalsEffect extends Node

@onready var path: Path3D = $Path

@export var particles: Array[GPUParticles3D]
@export var path_offset: float = 1.0


func _ready() -> void:
	for i in range(4): path.curve.add_point(Vector3.ZERO)


func set_path(start: Vector3, end: Vector3) -> void:
	path.curve.set_point_position(0, start)
	path.curve.set_point_position(3, end)
	var dir: Vector3 = end - start
	var flat_dir := Vector3(dir.x, 0.0, dir.z)
	if flat_dir.length_squared() < 0.0001: flat_dir = Vector3.FORWARD
	flat_dir = flat_dir.normalized()
	var right: Vector3 = flat_dir.cross(Vector3.UP).normalized()
	var first_inter := start + dir * 0.333 + right * path_offset
	var second_inter := start + dir * 0.666 - right * path_offset
	path.curve.set_point_position(1, first_inter)
	path.curve.set_point_position(2, second_inter)


func play_effect(start: Vector3, end: Vector3) -> void:
	set_path(start, end)
	for particle in particles:
		particle.global_position = start
