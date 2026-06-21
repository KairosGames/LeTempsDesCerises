class_name ColorRandomizer extends Node

@export var material: ShaderMaterial
@export var colors: Array[Color]

@export var property: String = "color"

func _ready() -> void:
	if material and colors.size(): material.set_shader_parameter("color", colors.pick_random())
