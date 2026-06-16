class_name Npc extends CharacterBody3D

signal arrived_on_path_point
signal arrived_on_path_destination
signal shot

@export var animator: AnimationPlayer

@onready var collider: CollisionShape3D = %Collider
@onready var is_on_screen: VisibleOnScreenNotifier3D = %IsOnScreen
@onready var nav: NavigationAgent3D = %Navigation

enum NpcName{
	Georges,
	Jules,
	François,
	Michel,
	Louise,
	Marie,
	Woman1,
	Woman2,
	Woman3,
	Versaillais,
	Random
}

enum NpcGender{
	Male,
	Female,
	NoBinary
}

enum NpcTeam{
	Communard,
	Versaillais
}

@export_category("Packed Scenes")
@export var versaillais: PackedScene
@export var communard: PackedScene

@export_category("Settings")
@export var npc_name: NpcName
@export var gender: NpcGender
@export var team: NpcTeam

var game_manager: GameManager
var on_process: Array[Callable]
var on_physics_process: Array[Callable]
var delta_t: float
var delta_p: float
var is_alive: bool = true
var is_figthing: bool = false
var is_nav_finished: bool = false
var is_all_nav_finished: bool = false

var rot_twn: Tween


func _ready() -> void:
	ready_deferred.call_deferred()


func ready_deferred() -> void:
	if GameManager.instance: game_manager = GameManager.instance


func _process(delta: float) -> void:
	delta_t = delta
	if is_alive: apply_gravity()
	for callable: Callable in on_process: callable.call()
	handle_animations()


func _physics_process(delta: float) -> void:
	delta_p = delta
	for callable: Callable in on_physics_process: callable.call()


func clean_process() -> void:
	on_process.clear()


func clean_physics_process() -> void:
	on_physics_process.clear()


func wait_until(condition: Callable) -> void:
	while not condition.call() or not game_manager.is_game_playing():
		await get_tree().process_frame


func move_to(pos: Vector3, speed: float) -> void:
	var dir: Vector3 = (pos - global_position).normalized()
	velocity = dir * speed
	while not is_at_point(pos):
		move_and_slide()
		if not is_alive: break
		await get_tree().process_frame
	velocity = Vector3.ZERO


func apply_gravity() -> void:
	if is_on_floor():
		velocity.y = 0.0
		return
	if not Player.instance: return
	velocity += get_gravity() * Player.instance.gravity_multiplier * delta_t


func rotate_yaw_to_pos(pos: Vector3, speed: float, delta: float) -> void:
	var dir = global_position - pos
	var target_angle = atan2(-dir.x, -dir.z)
	global_rotation.y = rotate_toward(global_rotation.y, target_angle, speed * delta)


func rotate_yaw_to_pos_tween(pos: Vector3, time: float, fight: bool = false) -> void:
	var dir = pos.direction_to(global_position)
	var target_angle = atan2(-dir.x, -dir.z)
	if rot_twn: rot_twn.kill()
	rot_twn = create_tween()
	var delta: float = wrapf(target_angle - global_rotation.y, -PI, PI)
	await rot_twn.tween_property(self, "global_rotation:y", delta, time).as_relative().finished
	is_figthing = fight


func is_at_point(pos: Vector3) -> bool:
	return global_position.distance_squared_to(pos) < 0.02


func move_forward(speed: float) -> void:
	velocity = basis.z * speed
	move_and_slide()


func die() -> void:
	var twn: Tween = create_tween()
	twn.tween_property(self, "velocity", Vector3.ZERO, 0.1)
	is_alive = false
	collider.disabled = true
	animator.play("stand-die", 0.3)


func handle_animations() -> void:
	var lateral_vel: float = Vector3(velocity.x, 0.0, velocity.z).length_squared()
	if lateral_vel >= 0.1:
		enter_in_walk_anim()
		return
	if is_figthing:
		enter_in_fight_anim()
		return


func enter_in_idle_anim() -> void:
	#if not animator.current_animation == "stand-moving":
		#animator.play("stand-moving")
	pass


func enter_in_walk_anim() -> void:
	pass


func enter_in_fight_anim() -> void:
	pass


func enter_in_crouch_anim() -> void:
	pass


func enter_in_aim() -> void:
	pass


func shoot() -> void:
	shot.emit()


func enter_in_stand_no_weapon() -> void:
	pass


func enter_reload() -> void:
	pass


func launch_movement_to_paths(path_points: Array[Node3D], speed: float, fight: bool = false) -> void:
	is_all_nav_finished = false
	for point: Node3D in path_points:
		is_nav_finished = false
		nav.target_position = point.global_position
		on_physics_process.push_back(go_to_nav_destination.bind(speed))
		await wait_until(is_on_nav_destination)
		arrived_on_path_point.emit()
	var dest: Node3D = path_points[path_points.size() - 1]
	var targ: Vector3 = dest.global_position + dest.basis.z
	await rotate_yaw_to_pos_tween(targ, 0.2)
	is_all_nav_finished = true
	arrived_on_path_destination.emit()
	is_figthing = fight


func launch_movement_to_nav_point(point: Node3D, speed: float, fight: bool = false) -> void:
	var solo: Array[Node3D] = [point]
	launch_movement_to_paths(solo, speed, fight)


func go_to_nav_destination(speed: float) -> void:
	if nav.is_navigation_finished():
		is_nav_finished = true
		clean_physics_process()
		return
	var next_pos: Vector3 = nav.get_next_path_position()
	rotate_yaw_to_pos(next_pos, PI * 2, delta_t)
	var dir = global_position - next_pos
	var target_angle = atan2(-dir.x, -dir.z)
	if abs(wrapf(global_rotation.y - target_angle, -PI, PI)) < PI * 0.1:
		move_forward(speed)


func is_on_nav_destination() -> bool:
	return is_nav_finished


func is_on_all_nav_finished() -> bool:
	return is_all_nav_finished


func replace_with_agent() -> void:
	var agent: Agent
	match team:
		NpcTeam.Communard: agent = communard.instantiate() as Agent
		NpcTeam.Versaillais: agent = versaillais.instantiate() as Agent
	get_parent().add_child(agent)
	agent.global_position = global_position
	agent.global_rotation = global_rotation
	agent.global_rotation.y += PI
	queue_free.call_deferred()


func wait_nav_to_aim() -> void:
	await get_tree().create_timer(0.1).timeout
	await wait_until(is_on_all_nav_finished)
	enter_in_aim()


func delay_shoot(rdn_min: float = 0.0, rnd_max: float = 1.0) -> void:
	var rnd: float = randf_range(rdn_min, rnd_max)
	await get_tree().create_timer(rnd).timeout
	shoot()
