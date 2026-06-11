class_name WomanPoints extends Node

@export_category("Women")
@export var women: Array[Npc]

@export_category("Markers")
@export var first_points: Dictionary[String, CustomMarker]
@export var second_points: Dictionary[String, CustomMarker]


func set_first_points() -> void:
	for woman: Npc in women:
		woman.nav.target_position = first_points[Npc.NpcName.keys()[woman.npc_name]].global_position


func set_second_points() -> void:
	for woman: Npc in women:
		woman.nav.target_position = second_points[Npc.NpcName.keys()[woman.npc_name]].global_position


func set_first_point(woman: Npc) -> void:
	woman.nav.target_position = first_points[Npc.NpcName.keys()[woman.npc_name]].global_position


func get_first_point(woman: Npc) -> CustomMarker:
	return first_points[Npc.NpcName.keys()[woman.npc_name]]


func set_second_point(woman: Npc) -> void:
	woman.nav.target_position = second_points[Npc.NpcName.keys()[woman.npc_name]].global_position


func get_second_point(woman: Npc) -> CustomMarker:
	return second_points[Npc.NpcName.keys()[woman.npc_name]]
