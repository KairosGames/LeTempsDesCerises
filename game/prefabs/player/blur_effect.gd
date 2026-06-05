class_name BlurEffect extends ColorRect

@onready var shader: ShaderMaterial = material as ShaderMaterial

@export var closed_size: float = 10.0
@export var a_closed_size: float = 8.0
@export var a_open_size: float = 2.0
@export var open_size: float = 0.0

var s_blur_size: String = "shader_parameter/blur_size"
