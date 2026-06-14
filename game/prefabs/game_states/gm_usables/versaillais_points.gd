class_name VersaillaisPoints extends Node

@export var all_versaillais: Array[Npc]
@export var spawn_points: Array[CustomMarker]
@export var dialogue_points: Array[CustomMarker]
@export var final_points: Array[CustomMarker]


func _ready() -> void:
	for versaillais: Npc in all_versaillais: versaillais.visible = false


func set_all_versaillais_spwan_pos() -> void:
	var i: int = 0
	for versaillais: Npc in all_versaillais:
		versaillais.global_position = spawn_points[i].global_position
		versaillais.global_rotation = spawn_points[i].global_rotation
		versaillais.visible = true
		i += 1


func all_versaillais_go_to_dialogue_pos() -> void:
	var i: int = 0
	for versaillais: Npc in all_versaillais:
		versaillais.launch_movement_to_nav_point(dialogue_points[i], 5.0)
		if i != 0: versaillais.wait_nav_to_aim()
		i += 1


func set_all_versaillais_final_pos() -> void:
	var i: int = 0
	for versaillais: Npc in all_versaillais:
		versaillais.global_position = final_points[i].global_position
		versaillais.global_rotation = final_points[i].global_rotation
		i += 1
