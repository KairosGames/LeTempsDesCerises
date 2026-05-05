class_name GameManager extends Node

static var active_fight_area: FightArea

@export_category("Export settings")
@export var player: Player


func _ready() -> void:
	player.on_death.connect(handle_death)


func handle_death() -> void:
	pass
