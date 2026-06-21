class_name DeathPetalsEffect extends Node3D

@onready var path: Path3D = $Path

@export_category("References")
@export var particles: Array[GPUParticles3D]

@export_category("First wave")
@export var wave_1_right_amplitude: float = 0.1
@export var wave_1_up_amplitude: float = 0.1
@export var wave_1_length: float = 1.0

@export_category("Second wave")
@export var wave_2_right_amplitude_min: float = 0.3
@export var wave_2_right_amplitude_max: float = 0.5
@export var wave_2_up_amplitude_min: float = 0.1
@export var wave_2_up_amplitude_max: float = 0.3
@export var wave_2_length: float = 2.0
@export var point_count: int = 128


var path_progress: float = 0.0:
	set(value):
		path_progress = value
		global_position = path.curve.sample_baked(value * path.curve.get_baked_length())


func _ready() -> void:
	for i: int in range(4): path.curve.add_point(Vector3.FORWARD * 0.001 * i)


func set_path(start: Vector3, end: Vector3) -> void:
	path.curve.clear_points()
	var dir: Vector3 = end - start
	var distance: float = dir.length()
	if distance < 0.001: return

	var flat_dir: Vector3 = Vector3(dir.x, 0.0, dir.z)
	if flat_dir.length_squared() < 0.0001: flat_dir = Vector3.FORWARD
	flat_dir = flat_dir.normalized()
	var right: Vector3 = flat_dir.cross(Vector3.UP).normalized()
	
	var wave_2_amplitude: float = randf_range(wave_2_right_amplitude_min, wave_2_right_amplitude_max)
	var wave_2_up_amplitude: float = randf_range(wave_2_up_amplitude_min, wave_2_up_amplitude_max)
	var wave_2_phase: float = randf() * TAU
	
	for i: int in range(point_count):
		var t: float = float(i) / float(point_count - 1)
		var real_dist: float = t * distance
		var base_pos: Vector3 = start + dir * t
		var side_wave_1: float = sin((real_dist / wave_1_length) * TAU) * wave_1_right_amplitude
		var side_wave_2: float = sin((real_dist / wave_2_length) * TAU + wave_2_phase) * wave_2_amplitude
		var up_wave_1: float = cos((real_dist / wave_1_length) * TAU) * wave_1_up_amplitude
		var up_wave_2: float = cos((real_dist / wave_2_length) * TAU + wave_2_phase) * wave_2_up_amplitude
		var final_pos: Vector3 = base_pos + right * (side_wave_1 + side_wave_2) + Vector3.UP * (up_wave_1 + up_wave_2)
		if i == 0: final_pos = start
		elif i == point_count - 1: final_pos = end
		path.curve.add_point(final_pos)


func play_effect(start: Vector3, end: Vector3, time: float) -> void:
	set_path(start, end)
	set_emission(true)
	path_progress = 0.0
	var twn: Tween = create_tween()
	twn.tween_property(self, "path_progress", 1.0, time)
	twn.tween_callback(set_emission.bind(false))


func set_emission(activate: bool) -> void:
	if not activate: await get_tree().create_timer(0.1).timeout
	for particle: GPUParticles3D in particles:
		particle.emitting = activate
