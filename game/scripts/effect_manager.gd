class_name EffectManager extends Node

enum EffectType {
	PlayerShoot,
	PnjShoot
	}

@export var instances_per_pool: int = 20
@export var effects_dic: Dictionary[EffectType, PackedScene]
var effects_list_dic: Dictionary[EffectType, Array]

func _ready() -> void:
	for effect_type in effects_dic:
		effects_list_dic[effect_type] = []
		for i in range(0, instances_per_pool):
			var new_vfx: ParticlesPlayer = effects_dic[effect_type].instantiate()
			new_vfx.position = Vector3(0.0, -5.0, 0.0)
			add_child(new_vfx, true)
			effects_list_dic[effect_type].push_back(new_vfx)


func play_effect(effect_type: EffectType, glb_position: Vector3) -> void:
	var particle_player: ParticlesPlayer
	for particle: ParticlesPlayer in effects_list_dic[effect_type]:
		if particle.is_free:
			particle_player = particle
			break
	
	if not particle_player:
		var new_vfx = effects_dic[effect_type].instantiate()
		add_child(new_vfx, true)
		effects_list_dic[effect_type].push_back(new_vfx)
		particle_player = new_vfx
	
	particle_player.global_position = glb_position
	particle_player.play_effect()
