extends Node3D

@export var damaged : AkEvent3D

func _enter_tree() -> void:
	WwiseGlobal.barricade = self

func _on_barricade_damaged() -> void:
	damaged.post_event()
