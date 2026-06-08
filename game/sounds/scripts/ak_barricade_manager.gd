extends Node3D

@export var damaged : AkEvent3D

var life : int

func _enter_tree() -> void:
	WwiseGlobal.barricade = self

func _on_barricade_damaged() -> void:
	life = get_parent().curr_life
	damaged.post_event()
