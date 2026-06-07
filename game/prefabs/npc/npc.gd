class_name Npc extends CharacterBody3D

@onready var animator: AnimationPlayer = %AnimationPlayer
@onready var collider: CollisionShape3D = %Collider


enum NpcName{
	Georges,
	Jules,
	François
}

enum NpcGender{
	Male,
	Female,
	NoBinary
}

@export var npc_name: NpcName
@export var gender: NpcGender

var on_process: Array[Callable]
var delta_t: float
var is_alive: bool = true
var is_figthing: bool = false

var rot_twn: Tween


func _process(delta: float) -> void:
	delta_t = delta
	if is_alive: apply_gravity()
	for callable: Callable in on_process: callable.call()
	handle_animations()


func clean_process() -> void:
	on_process.clear()


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


func rotate_yaw_to_pos(pos: Vector3, speed: float) -> void:
	var dir = global_position - pos
	var target_angle = atan2(-dir.x, -dir.z)
	global_rotation.y = rotate_toward(global_rotation.y, target_angle, speed * delta_t)


func rotate_yaw_to_pos_tween(pos: Vector3, time: float) -> void:
	var dir = global_position - pos
	var target_angle = atan2(-dir.x, -dir.z)
	if rot_twn: rot_twn.kill()
	rot_twn = create_tween()
	var delta: float = wrapf(target_angle - global_rotation.y, -PI, PI)
	await rot_twn.tween_property(self, "global_rotation:y", delta, time).as_relative().finished


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
	animator.play("death")


func handle_animations() -> void:
	var lateral_vel: float = Vector3(velocity.x, 0.0, velocity.z).length_squared()
	if lateral_vel >= 0.1:
		enter_in_walk_anim()
		return
	if is_figthing:
		enter_in_fight_anim()
		return
	enter_in_idle_anim()


func enter_in_idle_anim() -> void:
	pass


func enter_in_walk_anim() -> void:
	pass


func enter_in_fight_anim() -> void:
	pass
