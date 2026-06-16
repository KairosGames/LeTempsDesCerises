class_name VersaillaisPoints extends Node

@export_category("References")
@export var all_versaillais: Array[Npc]
@export var spawn_points: Array[CustomMarker]
@export var dialogue_points: Array[CustomMarker]
@export var final_points: Array[CustomMarker]

@export_category("Settings")
@export var louise_killers: Array[int]
@export var francois_killers: Array[int]
@export var player_killers: Array[int]


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
		versaillais.collider.disabled = true
		versaillais.launch_movement_to_nav_point(dialogue_points[i], 5.0)
		if i != 0: versaillais.wait_nav_to_aim()
		i += 1


func set_all_versaillais_final_pos() -> void:
	var i: int = 0
	for versaillais: Npc in all_versaillais:
		versaillais.global_position = final_points[i].global_position
		versaillais.global_rotation = final_points[i].global_rotation
		i += 1


func versillais_shoot_for_execution() -> void:
	for versaillais: Npc in all_versaillais: versaillais.delay_shoot()


func versaillais_kill_louise() -> void:
	for i: int in louise_killers: all_versaillais[i].delay_shoot(0.0, 0.3)


func versaillais_kill_francois() -> void:
	for i: int in francois_killers: all_versaillais[i].delay_shoot(0.0, 0.3)


func versaillais_kill_player() -> void:
	for i: int in player_killers: all_versaillais[i].delay_shoot(0.0, 0.3)
