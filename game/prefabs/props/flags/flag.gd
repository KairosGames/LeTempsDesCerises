class_name Flag extends Node3D

@onready var soft_flag: SoftBody3D = %SoftFlag

var shader_mat: ShaderMaterial
var twn: Tween


func _ready() -> void:
	shader_mat = soft_flag.get_surface_override_material(0) as ShaderMaterial


func fade_to_final_state(time: float) -> void:
	if twn: twn.kill()
	twn = create_tween()
	print("ça passe ici")
	twn.tween_property(shader_mat, "shader_parameter/factor", 1.0, time)
