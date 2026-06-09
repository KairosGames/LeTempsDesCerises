class_name Shake extends Node3D

@export var simple_shake_duration: float
@export var simple_shake_intensity: float
@export var simple_shake_speed: float = 10.0

var is_shaking := false
var shake_duration: float = 0.2
var shake_intensity: float = 0.1
var shake_speed: float = 10.0
var shake_time: float = 0.0
var original_position: Vector3
var noise: FastNoiseLite = FastNoiseLite.new()


func _ready() -> void:
	original_position = position
	noise.seed = randi()
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	noise.frequency = 6.0


func simple_shake() -> void:
	if is_shaking: return
	shake_intensity = simple_shake_intensity
	shake_speed = simple_shake_speed
	shake_duration = simple_shake_duration
	launch_shake()


func shake(intensity: float = 0.1, speed: float = 10.0,  duration: float = 0.2) -> void:
	if is_shaking: return
	shake_intensity = intensity
	shake_speed = speed
	shake_duration = duration
	launch_shake()


func launch_shake() -> void:
	is_shaking = true
	original_position = position
	shake_time = 0.0
	var tween: Tween = create_tween()
	var steps: int = int(shake_duration / 0.01)
	for i in steps:
		tween.tween_callback(Callable(self, "update_shake"))
		tween.tween_interval(0.01)
	tween.tween_callback(Callable(self, "stop_shake"))


func update_shake() -> void:
	shake_time += 0.01
	var x: float = noise.get_noise_1d(shake_time * shake_speed)
	var y: float = noise.get_noise_1d((shake_time + 1000.0) * shake_speed)
	
	
	#var offset: Vector3 = Vector3(x, y, 0.0) * shake_intensity
	var progress: float = shake_time / shake_duration
	var fade: float = 1.0 - smoothstep(0.0, 1.0, progress)
	var offset: Vector3 = Vector3(x, y, 0.0) * shake_intensity * fade
	
	position = original_position + offset


func stop_shake() -> void:
	position = original_position
	is_shaking = false
