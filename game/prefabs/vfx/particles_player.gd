class_name ParticlesPlayer extends Node3D

@export_category("Settings")
@export var worksWithAnimation: bool = false

@export_category("Particles")
@export var particles: Array[GeometryInstance3D]

@export_category("Animator")
@export var animationPlayer: AnimationPlayer

var is_free: bool = true


func play_effect() -> void:
	if worksWithAnimation:
		play_animation()
	else:
		trigger_all_particles()


func trigger_all_particles() -> void:
	for p in particles:
		if p is CPUParticles3D or p is GPUParticles3D:
			p.restart()
	is_free = false
	await get_tree().create_timer(get_max_lifetime()).timeout
	is_free = true


func get_max_lifetime() -> float:
	var max_time = 0.0
	for p in particles:
		if p is CPUParticles3D or p is GPUParticles3D:
			var time = p.lifetime
			max_time = max(max_time, time)
	return max_time


func play_animation() -> void:
	animationPlayer.play(animationPlayer.get_animation_list()[1])
	is_free = false


func free_animation():
	is_free = true
