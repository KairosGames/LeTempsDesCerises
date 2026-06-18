class_name Agent extends CharacterBody3D

@warning_ignore_start("unused_signal")
signal shoot
signal dying
signal died
signal posture_changed(posture: Posture)
signal reload_started
signal reload_ended
signal move_started
signal move_stoped
@warning_ignore_restore("unused_signal")

@export var team: Team = Team.VERSAILLAIS

@onready var shoot_raycast: RayCast3D = $RayCast3D
@onready var navigation: Navigation = $Navigation
@onready var animation: AnimationPlayer = $Body/AnimationPlayer
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var shoot_targets: Array[Marker3D] = [$ShootTargets/Chest, $ShootTargets/Head]
@onready var playback: AnimationNodeStateMachinePlayback = animation_tree.get("parameters/playback")

var is_disabled: bool = false
var has_enemy_in_range: bool = false
var can_die: bool = true
var is_alive: bool = true
var is_aiming: bool = false
var is_moving: bool = false
var is_shooting: bool = false
var is_weapon_loaded: bool = true
var target_object: Node3D = null
var target_point: Node3D = null
var threats: Array
var is_pushing_canon: bool = false
var posture: Posture = Posture.STAND:
	set(value):
		posture = value;
		posture_changed.emit(posture);
		_update_collider(posture)
var canon_slot: Marker3D = null:
	set(value):
		canon_slot = value
		if cover: cover = null
var is_reloading = false:
	set(value):
		is_reloading = value
		if value: reload_started.emit()
		else: reload_ended.emit()
var can_move: bool = true:
	set(value):
		can_move = value
		if not can_move: navigation.stop()
@export var cover: Cover = null:
	set(value):
		if cover: cover.holder = null
		cover = value
		if cover: cover.holder = self

@onready var body_parts: Array[MeshInstance3D] = [$Body/Armature/Skeleton3D/Ch49_body1, $Body/Armature/Skeleton3D/Ch49_body2]


enum Team { VERSAILLAIS = -1, NONE = 0, COMMUNARD = 1 }

func _ready() -> void:
	shoot_raycast.debug_shape_custom_color = Color.RED if team == Team.COMMUNARD else Color.BLUE


const threat_duration: float = 10

func add_threat(agent: Agent) -> void:
	if not threats.has(agent):
		threats.append(agent)
		if not agent.died.is_connected(remove_threat):
			agent.died.connect(remove_threat.bind(agent), CONNECT_ONE_SHOT)
		get_tree().create_timer(threat_duration).timeout.connect(remove_threat_timeout.bind(agent), CONNECT_ONE_SHOT)

func remove_threat(agent: Agent) -> void: threats.erase(agent)

@warning_ignore("untyped_declaration") # timeout callback failing to cast null to Agent
func remove_threat_timeout(agent) -> void: if agent: threats.erase(agent)

func on_start_moving() -> void:
	move_started.emit()
	is_moving = true
	playback.travel(&"stand-moving")

func on_stop_moving() -> void:
	move_stoped.emit()
	is_moving = false

func shoot_anim() -> void:
	shoot.emit()
	is_shooting = true
	var target: StringName
	match posture:
		Posture.PRONE: target = "prone-shoot"
		Posture.CROUCH: target = "crouch-shoot"
		Posture.STAND: target = "stand-shoot"
	playback.travel(target)
	is_shooting = false

func rotating_to(new_rotation: float, duration: float = 1.0) -> void:
	var tween: Tween = create_tween()
	tween.tween_property(self,"global_rotation:y", new_rotation, duration)
	await tween.finished

#func look(target: Vector3, duration: float = 1.0) -> void:
	#var target_angle: float = global_position.angle_to(target)
	#var tween: Tween = create_tween()
	#tween.tween_method(func(v): rotation.y = lerp_angle(rotation.y, target_angle, v), 0.0, 1.0, duration)
	#await tween.finished

func die() -> void:
	if not can_die or not is_alive: return
	is_alive = false
	is_pushing_canon = false
	dying.emit()
	set_collision_layer_value(3, false)
	navigation.stop()
	cover = null
	var tween: Tween = create_tween()
	tween.tween_method(
		func(transparency: float) -> void:
			for mesh: MeshInstance3D in body_parts:
				mesh.transparency = transparency
	,0.0, 1.0, 10.0)
	await tween.finished
	remove()

func remove() -> void:
	cover = null
	died.emit()
	queue_free()

@onready var collider: CollisionShape3D = $CollisionShape3D
@onready var collider_shape: CapsuleShape3D = collider.shape

func _update_collider(new_posture: Posture) -> void:
	match new_posture:
		Posture.PRONE:
			collider.position = Vector3(0, 0.25 , 0)
			collider_shape.height = 1.6
			collider_shape.radius = 0.25
			collider.rotation = Vector3(PI/2, 0, 0)
		Posture.CROUCH:
			collider.position = Vector3(0, 0.575 , -0.25)
			collider_shape.height = 1.15
			collider_shape.radius = 0.3
			collider.rotation = Vector3.ZERO
		Posture.STAND:
			collider.position = Vector3(0, 0.9 , 0)
			collider_shape.height = 1.8
			collider_shape.radius = 0.25
			collider.rotation = Vector3.ZERO

enum Posture { NONE, PRONE, CROUCH, STAND}
enum Sexe { MAN = 1, WOMAN = 2, BOTH = 3}
