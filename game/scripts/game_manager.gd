class_name GameManager extends Node

static var active_fight_area: FightArea

@export_category("References")
@export var player: Player
@export var first_barricade: Barricade

var step: int = 0


func get_active_barricade() -> Barricade:
	if step == 0: return first_barricade
	return null
