class_name DeathCamera extends Camera3D

@onready var player: Player = get_parent()
@onready var death_petals: DeathPetalsEffect = %DeathPetals
@onready var blink_effect: BlinkEffect = %BlinkEffect
@onready var death_ground_cast: RayCast3D = %DeathGroundCast

@export_category("Settings")
@export var time_to_swap: float = 3.0
@export var fall_time_1: float = 0.4
@export var fall_time_2: float = 0.5

var first_pos: Vector3
var first_rot: Vector3
var revive_pos: Vector3
var revive_rot: Vector3
var is_repop_on_communard: Vector3
var target_communard: Node3D
var is_active: bool

var fall_twn: Tween
var fall_rot_twn: Tween
var fov_twn: Tween


func _ready() -> void:
	first_pos = player.global_position
	first_rot = player.global_rotation


func handle_death(is_scripted: bool) -> void:
	var p_cam: Camera3D = player.player_camera
	fov = p_cam.fov
	global_position = p_cam.global_position
	global_rotation = p_cam.global_rotation
	current = true
	is_active = true
	if is_scripted:
		play_scripted_death()
		return
	play_death_effect()


func play_death_effect() -> void:
	var communard: Agent = get_free_communard()
	death_ground_cast.force_raycast_update()
	var ground_y: float = death_ground_cast.get_collision_point().y
	fall_twn = create_tween()
	fall_rot_twn = create_tween()
	fov_twn = create_tween()
	fall_twn.tween_property(self, "global_position:y", ground_y + 0.3, fall_time_1).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	fall_twn.tween_property(self, "global_position:y", ground_y + 0.1, fall_time_2).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	fov_twn.tween_property(self, "fov", player.default_fov, fall_time_1)

	if communard:
		play_eyes_effect_and_revive(true)
		communard.can_die = false
		communard.can_move = false
		handle_camera_on_communard(communard, ground_y)
		fall_twn.tween_callback(play_death_petals_effect.bind(self, communard))
		return

	play_eyes_effect_and_revive(false)
	handle_camera_simple_move()


func handle_camera_on_communard(communard: Node3D, ground: float) -> void:
	var to_target: Vector3 = communard.global_position - global_position
	to_target.y = 0.0
	to_target = to_target.normalized()
	var target_yaw: float = atan2(-to_target.x, -to_target.z)
	var current_rot: Vector3 = global_rotation
	var yaw_delta: float = wrapf(target_yaw - current_rot.y, -PI, PI)
	var final_yaw: float = current_rot.y + yaw_delta
	var side: float = -sign(yaw_delta)
	if side == 0.0: side = 1.0
	var fall_angle: float = deg_to_rad(90.0)
	var fall_rot: Vector3 = Vector3(current_rot.x, final_yaw, current_rot.z + fall_angle * side)
	fall_rot_twn.tween_property(self, "global_rotation", fall_rot, 0.45).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)

	var second_targ: Vector3 = communard.global_position + Vector3(0.0, 1.5, 0.0)
	var start_transform: Transform3D = global_transform
	start_transform.origin.y = ground + 0.1
	start_transform.basis = Basis.from_euler(fall_rot)
	var up_dir: Vector3 = start_transform.basis.y.normalized()
	var look_transform: Transform3D = start_transform.looking_at(second_targ, up_dir)
	var start_quat: Quaternion = start_transform.basis.get_rotation_quaternion()
	var target_quat: Quaternion = look_transform.basis.get_rotation_quaternion()
	fall_rot_twn.tween_method(
		func(t: float) -> void: global_transform.basis = Basis(start_quat.slerp(target_quat, t)),
		0.0, 1.0, 0.1)

	await get_tree().create_timer(time_to_swap).timeout
	var offset_rot: Vector3 = Vector3(0.0, PI, 0.0) if communard is Agent else Vector3.ZERO
	revive_pos = communard.global_position
	revive_rot = Vector3(0, communard.global_rotation.y, 0) + offset_rot
	target_communard = communard
	
	#fov_twn = create_tween()
	#fov_twn.tween_property(self, "fov", 120.0, 0.2
				#).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	#await fov_twn.tween_property(self, "fov", 1.0, 0.25
				#).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC).finished


func handle_camera_simple_move() -> void:
	var z_rot: float = 90.0 if randi() % 2 else -90.0
	var fall_rot: Vector3 = Vector3(0.0, -z_rot, global_rotation_degrees.z + z_rot)
	fall_rot_twn.tween_property(self, "global_rotation_degrees", fall_rot, 0.3)
	await get_tree().create_timer(time_to_swap).timeout
	revive_pos = first_pos
	revive_rot = Vector3(0.0, first_rot.y, 0.0)


func play_eyes_effect_and_revive(is_on_communard: bool) -> void:
	blink_effect.blur_effect.set_blur_enable(true)
	blink_effect.blur_effect.hard_set_blur(0.5)
	
	blink_effect.move_eyes(BlinkEffect.EyesStep.A_OPEN, 0.3, true, 1.0)
	await get_tree().create_timer(fall_time_1 + fall_time_2).timeout
	
	await blink_effect.move_eyes(BlinkEffect.EyesStep.A_CLOSED, 0.3, true, 5.0)
	await blink_effect.move_eyes(BlinkEffect.EyesStep.A_OPEN, 0.5, true, 1.0)

	await get_tree().create_timer(0.5).timeout
	blink_effect.move_eyes(BlinkEffect.EyesStep.CLOSED, 0.4, true, 7.0)
	
	await get_tree().create_timer(0.2).timeout
	blink_effect.move_eyes(BlinkEffect.EyesStep.A_CLOSED, 1.0, true, 2.0)
	
	await get_tree().create_timer(0.8).timeout
	blink_effect.move_eyes(BlinkEffect.EyesStep.CLOSED, 0.2, true, 10.0)
	
	await get_tree().create_timer(0.5).timeout
	player.revive(revive_pos, revive_rot)
	if is_on_communard:
		if target_communard is Agent: 
			delete_swaped_communard(target_communard)
		elif target_communard is Npc:
			delete_npc(target_communard)
	is_active = false
	if fall_twn: fall_twn.kill()
	if fall_rot_twn: fall_rot_twn.kill()
	if fov_twn: fov_twn.kill()
	await blink_effect.move_eyes(BlinkEffect.EyesStep.OPEN, 0.1, true)
	blink_effect.set_blink_enable(false)
	blink_effect.blur_effect.set_blur_enable(false)


func play_death_petals_effect(camera: Node3D, communard: Node3D) -> void:
	var offset: Vector3 = Vector3(0.0, 1.5, 0.0) - (communard.basis.z * 0.2)
	death_petals.play_effect(camera.global_position, communard.global_position + offset, time_to_swap - 0.4)


func get_free_communard() -> Agent:
	var communards: Array = get_tree().get_nodes_in_group("Communard")
	var nearer_communard: Agent = null
	var max_dist: float = 300 * 300
	for communard in communards:
		if communard is Player: continue
		if not (communard as Agent).is_alive: continue
		var dist: float = player.global_position.distance_squared_to((communard as Agent).global_position)
		if dist < max_dist:
			max_dist = dist
			nearer_communard = communard
	return nearer_communard


func delete_swaped_communard(communard: Agent) -> void:
	communard.remove()


func play_scripted_death() -> void:
	var communard: Npc = GameManager.instance.curr_state.next_respawn
	var ground_y: float = player.global_position.y
	fall_twn = create_tween()
	fall_rot_twn = create_tween()
	fov_twn = create_tween()
	fall_twn.tween_property(self, "global_position:y", ground_y + 0.3, fall_time_1).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	fall_twn.tween_property(self, "global_position:y", ground_y + 0.1, fall_time_2).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	fov_twn.tween_property(self, "fov", player.default_fov, fall_time_1)
	play_eyes_effect_and_revive(true)
	handle_camera_on_communard(communard, ground_y)
	fall_twn.tween_callback(play_death_petals_effect.bind(self, communard))
	return


func delete_npc(communard: Node3D) -> void:
	communard.queue_free()
