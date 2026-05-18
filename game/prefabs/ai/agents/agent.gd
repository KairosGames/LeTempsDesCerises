class_name Agent extends CharacterBody3D

@warning_ignore_start("unused_signal")
signal shoot
signal died(agent: Agent)
signal posture_changed(posture: Posture)
#signal reload_start
#signal reload_end
@warning_ignore_restore("unused_signal")

@export var team: Team = Team.VERSAILLAIS

@onready var shoot_raycast: RayCast3D = $RayCast3D
@onready var navigation: Navigation = $Navigation
@onready var animation: AnimationPlayer = $Body/AnimationPlayer
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var shoot_targets: Array[Marker3D] = [$ShootTargets/Head]

var has_enemy_in_range: bool = false
var can_die: bool = true
var is_alive: bool = true
var is_weapon_loaded: bool = true
var target: Node3D = null
var target_point: Node3D = null
var threats: Array[Agent] = []
var is_pushing_canon: bool = false
var posture: Posture = Posture.STANDING:
	set(value): posture = value; posture_changed.emit(posture)
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
	animation_tree["parameters/Move & Shoot/Move/blend_position"] = 1.0

func on_stop_moving() -> void:
	animation_tree["parameters/Move & Shoot/Move/blend_position"] = 0.0

func reload_anim() -> void:
	pass

func shoot_anim() -> void:
	animation_tree["parameters/Move & Shoot/OneShot/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
	shoot.emit()

func die() -> void:
	if not can_die or not is_alive: return
	is_alive = false
	cover = null
	set_collision_layer_value(3, false)
	navigation.stop()
	await get_tree().create_timer(2.0).timeout
	died.emit(self)
	queue_free()

enum Posture { NONE, PRONE, CROUCHING, STANDING}
