class_name EffectsManager extends Node

signal impact_from_shoot(position: Vector3, direction, is_body: bool)

enum EffectType {
	PlayerShoot,
	PnjShoot
}

@export var instances_per_pool: int = 20

var EFFECT_PREFABS: Dictionary[EffectType, PackedScene] = {
	EffectType.PlayerShoot: preload("uid://cbwpfvcia7dju"),
	EffectType.PnjShoot: preload("uid://ckpkymdprs6dq")
}

var effects_list_dic: Dictionary[EffectType, Array]

static var instance: EffectsManager:
	set(value):
		if not instance: instance = value
		else: push_error("MORE THAN ONE EFF_MANAGER IN SCENE")


func _ready() -> void:
	instance = self
	for effect_type in EFFECT_PREFABS:
		effects_list_dic[effect_type] = []
		for i in range(0, instances_per_pool):
			var new_vfx: ParticlesPlayer = EFFECT_PREFABS[effect_type].instantiate()
			new_vfx.position = Vector3(0.0, -10.0, 0.0)
			add_child(new_vfx, true)
			effects_list_dic[effect_type].push_back(new_vfx)
		effects_list_dic[effect_type][0].play_effect()


func play_effect(eff_type: EffectType, glb_pos: Vector3, glb_rot: Vector3 = Vector3.ZERO) -> void:
	var particle_player: ParticlesPlayer
	for particle: ParticlesPlayer in effects_list_dic[eff_type]:
		if particle.is_free:
			particle_player = particle
			break
	
	if not particle_player:
		var new_vfx = EFFECT_PREFABS[eff_type].instantiate()
		add_child(new_vfx, true)
		effects_list_dic[eff_type].push_back(new_vfx)
		particle_player = new_vfx
	
	particle_player.global_position = glb_pos
	particle_player.global_rotation = glb_rot
	particle_player.play_effect()
