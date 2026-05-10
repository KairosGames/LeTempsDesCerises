extends Node

@export var damaged : AkEvent3D

func _on_barricade_damaged() -> void:
	damaged.post_event()
