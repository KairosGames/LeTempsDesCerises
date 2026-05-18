class_name DeathCamera extends Camera3D

@onready var player: Player = get_parent()

@export var time_to_swap: float = 3.0

var first_pos: Vector3
var first_rot: Vector3
var is_active: bool

var fall_twn: Tween
var fall_rot_twn: Tween
var fov_twn: Tween


func _ready() -> void:
	player.died.connect(handle_death)
	first_pos = player.global_position
	first_rot = player.global_rotation


func handle_death() -> void:
	var p_cam: Camera3D = player.player_camera
	fov = p_cam.fov
	global_position = p_cam.global_position
	global_rotation = p_cam.global_rotation
	current = true
	is_active = true
	play_fall_effect()


func play_fall_effect() -> void:
	var communard: Agent = get_free_communard()
	var ground_y: float = player.global_position.y
	fall_twn = create_tween()
	fall_rot_twn = create_tween()
	fov_twn = create_tween()
	fall_twn.tween_property(self, "global_position:y", ground_y + 0.3, 0.4).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	fall_twn.tween_property(self, "global_position:y", ground_y + 0.1, 0.5).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	fov_twn.tween_property(self, "fov", player.default_fov, 0.4)
	var fall_rot: Vector3
	
	if communard:
		communard.can_die = false
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
		fall_rot = Vector3(current_rot.x, final_yaw, current_rot.z + fall_angle * side)
		fall_rot_twn.tween_property(self, "global_rotation", fall_rot, 0.45).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
		
		var second_targ: Vector3 = communard.global_position + Vector3(0.0, 1.5, 0.0)
		#var second_targ: Vector3 = communard.shoot_targets[0].global_position
		var start_transform: Transform3D = global_transform
		start_transform.origin.y = ground_y + 0.1
		start_transform.basis = Basis.from_euler(fall_rot)
		var up_dir: Vector3 = start_transform.basis.y.normalized()
		var look_transform: Transform3D = start_transform.looking_at(second_targ, up_dir)
		var start_quat: Quaternion = start_transform.basis.get_rotation_quaternion()
		var target_quat: Quaternion = look_transform.basis.get_rotation_quaternion()
		fall_rot_twn.tween_method(
			func(t: float) -> void: global_transform.basis = Basis(start_quat.slerp(target_quat, t)),
			0.0, 1.0, 0.1)
		
		await get_tree().create_timer(time_to_swap).timeout
		fov_twn = create_tween()
		fov_twn.tween_property(self, "fov", 120.0, 0.2
					).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		await fov_twn.tween_property(self, "fov", 1.0, 0.25
					).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC).finished
		#await fov_twn.tween_property(self, "fov", 1.0, 0.45
					#).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK).finished
		var offset_rot: Vector3 = Vector3(0.0, PI, 0.0)
		player.revive(communard.global_position, communard.global_rotation + offset_rot)
		communard.can_die = true
		delete_swaped_communard(communard)
		is_active = false
		return
	
	var z_rot: float = 90.0 if randi() % 2 else -90.0
	fall_rot = Vector3(0.0, -z_rot, global_rotation_degrees.z + z_rot)
	fall_rot_twn.tween_property(self, "global_rotation_degrees", fall_rot, 0.3)
	await get_tree().create_timer(time_to_swap).timeout
	player.revive(first_pos, first_rot)
	is_active = false


func get_free_communard() -> Agent:
	var communards: Array = get_tree().get_nodes_in_group("Communard")
	var nearer_communard: Agent = null
	var max_dist: float = 300 * 300
	for communard in communards:
		if communard is Player: continue
		var dist: float = player.global_position.distance_squared_to((communard as Agent).global_position)
		if dist < max_dist:
			max_dist = dist
			nearer_communard = communard
	return nearer_communard


func delete_swaped_communard(communard: Agent) -> void:
	communard.cover = null
	communard.died.emit(communard)
	communard.queue_free()
