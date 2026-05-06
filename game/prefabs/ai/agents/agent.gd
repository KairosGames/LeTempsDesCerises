class_name Agent extends CharacterBody3D

@warning_ignore_start("unused_signal")
signal died
signal shoot
#signal reload_start
#signal reload_end
@warning_ignore_restore("unused_signal")

@export var team: Team = Team.VERSALLAIS

@onready var navigation: Navigation = $Navigation
@onready var animation: AnimationPlayer = $PlaceholderBody/AnimationPlayer
@onready var animation_tree: AnimationTree = $AnimationTree

var is_alive: bool = true
var is_weapon_loaded: bool = true
var is_covered: bool = false
var canon_slot: Marker3D = null:
	set(value):
		canon_slot = value
		if cover: cover = null
var cover: Cover = null:
	set(value):
		if cover: cover.holder = null
		cover = value
		if cover: cover.holder = self

enum Team { VERSALLAIS = -1, NONE = 0, COMMUNARD = 1 }

func aim_to(target: Vector3) -> void:
	target.y = global_position.y
	look_at(target)

func on_start_moving() -> void:
	animation_tree["parameters/MoveBlend/blend_position"] = 1.0

func on_stop_moving() -> void:
	animation_tree["parameters/MoveBlend/blend_position"] = 0.0

func reload_anim() -> void:
	pass

func shoot_anim() -> void:
	animation_tree["parameters/Shoot/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
	shoot.emit()

func die() -> void:
	if not is_alive: return
	is_alive = false
	cover = null
	navigation.stop()
	animation_tree["parameters/Die/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
	await animation_tree.animation_finished
	died.emit()
	queue_free()
