class_name BlurEffect extends ColorRect

@onready var shader: ShaderMaterial = material as ShaderMaterial

@export_category("Closed")
@export var closed_size: float = -0.2
@export var a_closed_size: float = -0.2
@export var a_open_size: float = -0.2
@export var open_size: float = 0.0
