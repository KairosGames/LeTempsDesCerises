class_name Agent extends CharacterBody3D

signal died

static var all: Array[Agent]

@onready var navigation: Navigation = $Navigation

@onready var animation: AnimationPlayer = $AnimationPlayer

@warning_ignore_start("unused_signal")
signal shoot
#signal reload_start
#signal reload_end
signal move_start
signal move_end
@warning_ignore_restore("unused_signal")

var is_weapon_loaded: bool = true
var is_alive: bool = true
var cover: Cover = null

@export var team: Team = Team.VERSALLAIS

enum Team { VERSALLAIS = -1, NONE = 0, COMMUNARD = 1 }

func aim_to(target: Vector3) -> void:
	target.y = global_position.y
	look_at(target)

func _ready() -> void:
	all.append(self)

func die() -> void:
	if not is_alive: return
	is_alive = false
	if cover: CoverManager.release(cover)
	all.erase(self)
	animation.play("die")
	navigation.stop()
	await animation.animation_finished
	died.emit()
	queue_free()
