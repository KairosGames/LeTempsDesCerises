class_name GameManager extends Node

static var active_fight_area: FightArea

@export_category("References")
@export var first_barricade: Barricade
@export var canon: Canon

var step: int = 0

static var instance: GameManager:
	set(value):
		if not instance: instance = value
		else: push_error("MORE THAN ONE GAME_MANAGER IN SCENE")


func _ready() -> void:
	instance = self
	if canon: canon.shoot.connect(handle_canon_shoot)


func handle_canon_shoot() -> void:
	var curr_barricade = get_active_barricade()
	if curr_barricade: curr_barricade.take_damage()


func get_active_barricade() -> Barricade:
	if step == 0: return first_barricade
	return null
