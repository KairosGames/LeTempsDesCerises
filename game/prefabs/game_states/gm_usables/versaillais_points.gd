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
		await get_tree().create_timer(0.05).timeout
		var aim: bool = i != 0
		versaillais.launch_movement_to_nav_point(dialogue_points[i], 5.0, false, aim)
		if i != 0: versaillais.wait_nav_to_aim()
		i += 1


func set_all_versaillais_final_pos() -> void:
	var i: int = 0
	for versaillais: Npc in all_versaillais:
		if i != 0: versaillais.enter_idle_execution(0.0)
		versaillais.global_position = final_points[i].global_position
		versaillais.global_rotation = final_points[i].global_rotation
		i += 1


func versaillais_enter_aiming() -> void:
	var i: int = 0
	for versaillais: Npc in all_versaillais:
		if i != 0: versaillais.enter_in_aim(0.35)
		i += 1


func versaillais_shoot_for_execution() -> void:
	for versaillais: Npc in all_versaillais: versaillais.delay_shoot(0.0, 1.0)


func versaillais_kill_louise(louise_targ: Node3D) -> void:
	for i: int in louise_killers: all_versaillais[i].delay_shoot(0.0, 0.3, louise_targ)


func versaillais_kill_francois(francois_targ: Node3D) -> void:
	for i: int in francois_killers: all_versaillais[i].delay_shoot(0.0, 0.3, francois_targ)


func versaillais_kill_player(player_targ: Node3D) -> void:
	for i: int in player_killers: all_versaillais[i].delay_shoot(0.0, 0.2, player_targ)
