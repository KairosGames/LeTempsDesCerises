class_name EffectManager extends Node

enum EffectType {
	ShootSmoke
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
