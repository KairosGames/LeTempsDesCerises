class_name ShootLightTrail extends Node3D

@onready var trail: MeshInstance3D = %Trail

var speed: float = 80.0
var twn: Tween


func shoot(destination: Vector3) -> void:
	trail.global_position = get_parent().global_position
	var dir: Vector3 = trail.global_position.direction_to(destination)
	var x_axis: Vector3 = dir.normalized()
	var y_axis: Vector3 = Vector3.UP
	if abs(x_axis.dot(y_axis)) > 0.99: y_axis = Vector3.FORWARD
	var z_axis: Vector3 = x_axis.cross(y_axis).normalized()
	y_axis = z_axis.cross(x_axis).normalized()
	trail.global_basis = Basis(x_axis, y_axis, z_axis)
	trail.visible = true
	var dist: float = global_position.distance_to(destination)
	var t: float = dist / speed
	if twn: twn.kill()
	twn = create_tween()
	twn.tween_property(trail, "global_position", destination, t)
	await twn.finished
	trail.visible = false
	trail.rotation = Vector3.ZERO
	trail.position = Vector3.ZERO
