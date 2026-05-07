class_name Agent extends CharacterBody3D

@warning_ignore_start("unused_signal")
signal shoot
signal died(agent: Agent)
#signal reload_start
#signal reload_end
@warning_ignore_restore("unused_signal")

@export var team: Team = Team.VERSAILLAIS

@onready var shoot_raycast: RayCast3D = $RayCast3D
@onready var navigation: Navigation = $Navigation
@onready var animation: AnimationPlayer = $PlaceholderBody/AnimationPlayer
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var shoot_targets: Array[Marker3D] = [$ShootTargets/Head]

var has_enemy_in_range: bool = false
var is_alive: bool = true
var is_weapon_loaded: bool = true
var target: Node3D = null
var target_point: Node3D = null
var threats: Array[Agent]
var is_covered: bool = false:
	set(value):
		is_covered = value
		animation_tree["parameters/Crouching/blend_amount"] = int(value)
var is_pushing_canon: bool = false
var canon_slot: Marker3D = null:
	set(value):
		canon_slot = value
		if cover: cover = null
@export var cover: Cover = null:
	set(value):
		if cover: cover.holder = null
		cover = value
		if cover: cover.holder = self

enum Team { VERSAILLAIS = -1, NONE = 0, COMMUNARD = 1 }

func aim_to(point: Vector3) -> void:
	point.y = global_position.y
	look_at(point)

const threat_duration: float = 10

func add_threat(agent: Agent) -> void:
	if not threats.has(agent):
		threats.append(agent)
		agent.died.connect(remove_threat, CONNECT_ONE_SHOT)
		get_tree().create_timer(threat_duration).timeout.connect(remove_threat.bind(agent), CONNECT_ONE_SHOT)

func remove_threat(agent) -> void: # Not typed lambda because of timeout callback failing to cast null to Agent
	if not agent: return
	if agent.died.is_connected(remove_threat):
		agent.died.disconnect(remove_threat)
	threats.erase(agent)

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
	set_collision_layer_value(3, false)
	navigation.stop()
	animation_tree["parameters/Die/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
	await animation_tree.animation_finished
	died.emit(self)
	queue_free()
