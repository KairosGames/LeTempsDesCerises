class_name CamLayerHandler extends Node3D

@export_category("Settings")
@export var switch_dist: float = 1.0

@export_category("References")
@export var gpu_particles: Array[GPUParticles3D]
@export var cpu_particles: Array[CPUParticles3D]

var particles: Array[VisualInstance3D]


func _ready() -> void:
	for gpu_part: GPUParticles3D in gpu_particles:
		particles.push_back(gpu_part as VisualInstance3D)
	for cpu_part: CPUParticles3D in cpu_particles:
		particles.push_back(cpu_part as VisualInstance3D)


func _process(_delta: float) -> void:
	return #TO POLISH (LOOKING FOR SOLUTION, RETURN FOR THE MOMENT)
	if not Player.instance: return
	var is_far: bool = Player.instance.global_position.distance_squared_to(global_position) >= pow(switch_dist, 2)
	for part: VisualInstance3D in particles:
			part.set_layer_mask_value(2, not is_far)
