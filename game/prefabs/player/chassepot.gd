class_name Chassepot extends Node3D

var call_load_ammo: Callable
var call_next_step: Callable

func load_ammo() -> void:
	call_load_ammo.call()

func next_step() -> void:
	call_next_step.call()
