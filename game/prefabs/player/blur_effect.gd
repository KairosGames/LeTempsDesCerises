class_name BlurEffect extends ColorRect

@onready var shader: ShaderMaterial = material as ShaderMaterial

@export var closed_size: float = 10.0
@export var a_closed_size: float = 8.0
@export var a_open_size: float = 2.0
@export var open_size: float = 0.0

var s_blur_size: String = "shader_parameter/blur_size"

var twn: Tween


func _ready() -> void:
	visible = false


func set_blur_enable(enable: bool) -> void:
	visible = enable


func hard_set_blur(value: float) -> void:
	shader.set_shader_parameter("blur_size", value)


func set_blur(value: float, time: float) -> void:
	if twn: twn.kill()
	twn = create_tween()
	await twn.tween_property(shader, s_blur_size, value, time).finished
