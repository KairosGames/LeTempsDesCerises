@tool
class_name TEST_GEN extends Node3D

@export_category("References")
@export var path_gen: PackedScene

@export_category("Settings")
@export var dir: Vector3 = Vector3.FORWARD
@export var var_angle: float = 180.0
@export var n_points: int = 50
@export var dist_btw: float = 0.1
@export var max_deepness: int = 5
#@export var start_thickness: float = 0.05
#@export var end_thickness: float = 0.005

var to_realease: bool = false


func _process(_delta):
	if not Input.is_key_pressed(KEY_F8): to_realease = false
	if Input.is_key_pressed(KEY_F8) and not to_realease:
		to_realease = true
		print("prout")
		start_generation()


func start_generation() -> void:
	for child in get_children():
		child.queue_free()
	return
	var strand: TEST_REND = path_gen.instantiate() as TEST_REND
	add_child(strand)
	strand.owner = get_parent()
	strand.generate_path(path_gen, Vector3.ZERO, 1, max_deepness, dir, var_angle, n_points, dist_btw)
