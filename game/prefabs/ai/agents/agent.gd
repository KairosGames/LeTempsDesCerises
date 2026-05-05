class_name Agent extends CharacterBody3D

@warning_ignore_start("unused_signal")
signal died
signal shoot
#signal reload_start
#signal reload_end
@warning_ignore_restore("unused_signal")

@export var team: Team = Team.VERSALLAIS

@onready var navigation: Navigation = $Navigation
@onready var animation: AnimationPlayer = $AnimationPlayer

var is_alive: bool = true
var is_weapon_loaded: bool = true
var is_covered: bool = false
var canon_slot: Marker3D = null
var cover: Cover = null:
	set(value):
		if cover: cover.holder = null
		cover = value
		if cover: cover.holder = self

enum Team { VERSALLAIS = -1, NONE = 0, COMMUNARD = 1 }

func aim_to(target: Vector3) -> void:
	target.y = global_position.y
	look_at(target)

func die() -> void:
	if not is_alive: return
	is_alive = false
	cover = null
	navigation.stop()
	animation.play("die")
	await animation.animation_finished
	died.emit()
	queue_free()
