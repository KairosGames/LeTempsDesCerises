class_name Chassepot extends Node3D

@onready var shoot_light_trail: ShootLightTrail = %ShootLightTrail
@onready var shoot_effect_point: Marker3D = get_node_or_null("ShootEffectPoint")

var call_load_ammo: Callable
var call_next_step: Callable


func load_ammo() -> void:
	call_load_ammo.call()


func next_step() -> void:
	call_next_step.call()


func play_light_trail(destination: Vector3) -> void:
	shoot_light_trail.shoot(destination)
