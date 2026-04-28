class_name Player extends CharacterBody3D

@onready var p_inputs: PlayerInputs = %PlayerInputs
@onready var reload_ui: ReloadUI = %ReloadUI
@onready var camera_pivot: Node3D = %CameraPivot
@onready var wpn_cam_base: Node3D = %WeaponCameraBase
@onready var player_camera: Camera3D = %PlayerCamera
@onready var weapon_container: Node3D = %WeaponContainer
@onready var right_weapon_pos: Marker3D = %RightWeaponPos
@onready var left_weapon_pos: Marker3D = %LeftWeaponPos
@onready var aim_pos: Marker3D = %AimPos
@onready var weapon_sway_root: Node3D = %WeaponSwayRoot
@onready var weapon_lag_root: Node3D = %WeaponLagRoot
@onready var lag_target: Node3D = %LagTarget
@onready var weapon_ray_cast: RayCast3D = %WeaponRayCast

@export_category("Exposed settings")
@export var is_aim_locked: bool = true
@export var is_run_locked: bool = false
@export var is_position_switcher_locked: bool = true
@export var is_aim_smooth: bool = true
@export var is_movement_smooth: bool = true

@export_category("Character settings")
@export var is_right_handed: bool = true

@export_category("View settings")
@export var v_clamp_deg: Vector2 = Vector2(-70.0, 70.0)
@export var v_clamp_prone: Vector2 = Vector2(-45.0, 45.0)
@export_range(0.01, 1.0, 0.01) var ads_speed_view_reduc: float = 0.4
@export_range(0.1, 1.0, 0.01) var prone_speed_view_reduc: float = 0.3

@export_category("ADS settings")
@export var default_fov: float = 75.0
@export var ads_fov: float = 65.0
@export var perfect_fov: float = 59.0
@export var time_to_ads: float = 0.4
@export var is_ads_rot_active: bool = false
@export var ads_z_rot: float = 1.0

@export_category("Sway settings")
@export var sway_pitch_len: float = 1.35
@export var sway_yaw_len: float = 1.0
@export var crouch_sway_reduc: float = 0.6
@export var prone_sway_reduc: float = 0.2
@export var sway_x_freq: float = 1.0
@export var sway_y_freq: float = 0.85
@export var sway_noise_len: float = 1.25
@export var sway_noise_freq: float = 2.5
@export var ads_concentration_curve: Curve

@export_category("Weapon lag settings")
@export var max_wp_xz_pos_lag: float = 0.015
@export var max_wp_y_pos_lag: float = 0.005
@export var wp_pos_lag_away_speed: float = 5.0
@export var wp_pos_lag_close_speed: float = 10.0
@export var ads_wp_pos_lag_reducer: float = 0.15
@export var max_wp_y_rot_lag_deg: float = 20.0
@export var max_wp_x_rot_lag_deg: float = 0.2
@export var wp_rot_lag_away_speed: float = 1.0
@export var wp_rot_lag_close_speed: float = 12.5

@export_category("States settings")
@export var state_switch_time: float = 0.2
@export var standing_height: float = 1.6
@export var crouch_height: float = 1.1
@export var prone_height: float = 0.35
@export_range(0.2, 1.0, 0.01) var gpad_mini_run_length: float = 0.5

@export_category("Movement speed settings")
@export var standing_speed: float = 4.0
@export var crouch_speed: float = 2.5
@export var prone_speed: float = 1.0
@export_range(0.0, 1.0, 0.01) var air_up_speed: float = 1.0
@export_range(1.0, 3.0, 0.01) var run_speed_ratio: float = 2.0
@export_range(0.0, 1.0, 0.01) var side_speed_ratio: float = 0.75
@export_range(0.0, 1.0, 0.01) var back_speed_ratio: float = 0.6
@export_range(0.0, 1.0, 0.01) var aiming_speed_ratio: float = 0.3

@export_category("Smoothness settings")
@export_range(0.01, 0.5, 0.01) var acc_time: float = 0.1
@export_range(0.01, 0.5, 0.01) var brake_time: float = 0.1
@export_range(0.01, 1.0, 0.001) var aim_smooth_strength: float = 0.05

var is_grounded: bool = true
var stop_run: bool = false
var is_aiming: bool = false
var is_running: bool = false
var is_crouched:bool = false
var is_prone: bool = false
var is_changing_state: bool = false

var can_shoot: bool = true
var has_weapon: bool = true
var is_weapon_loaded: bool = true
var is_reloading: bool = false

var aim_noise_x: FastNoiseLite = FastNoiseLite.new()
var aim_noise_y: FastNoiseLite = FastNoiseLite.new()
var curr_sway_len: Vector2
var curr_sway_noise_len: float
var sway_timer: float
var ads_timer: float
var concentration_sample: float

var applied_pos_lag_speed: float
var applied_rot_lag_speed: float

var aim_vel: Vector3 = Vector3.ZERO
var aim_target: Vector3 = Vector3.ZERO
var acc_time_ratio: float
var brake_time_ratio: float

var wpn_x_aim_twn: Tween
var wpn_y_aim_twn: Tween
var wpn_z_aim_twn: Tween
var fov_aim_twn: Tween
var cam_rot_aim_twn: Tween
var state_twn: Tween

const JUMP_VELOCITY = 4.5


func _ready() -> void:
	weapon_sway_root.visible = has_weapon
	weapon_container.position = right_weapon_pos.position if is_right_handed else left_weapon_pos.position
	aim_target = Vector3(camera_pivot.rotation_degrees.x, rotation_degrees.y, 0.0)
	acc_time_ratio = (1 / acc_time)
	brake_time_ratio = (1 / brake_time)
	aim_noise_x.seed = randi()
	aim_noise_y.seed = randi()
	curr_sway_len = Vector2(sway_pitch_len, sway_yaw_len)
	curr_sway_noise_len = sway_noise_len


func _process(delta: float) -> void:
	capture_states()
	process_movement(delta)
	process_view(delta)
	handle_weapon_movement(delta)
	handle_shoot()
	handle_reload()


func capture_states() -> void:
	set_context()
	if not p_inputs.is_mouse_locked(): return
	capture_aim_state()
	capture_run_state()
	capture_position_state()


func set_context() -> void:
	is_grounded = is_on_floor()
	var input_dir: Vector2 = p_inputs.move_vec
	stop_run = input_dir.y <= 0.0 or abs(input_dir.x) > 0.71 or input_dir.length() < gpad_mini_run_length


func capture_aim_state() -> void:
	var was_aiming: bool = is_aiming
	
	if can_aim():
		if is_aim_locked: handle_toggle_aim()
		else : handle_hold_aim()
	else : is_aiming = false
	
	p_inputs.is_aiming = is_aiming
	if was_aiming != is_aiming :
		switch_aim_state()


func can_aim() -> bool:
	if not has_weapon: return false
	if is_reloading: return false
	if not is_grounded: return false
	if Input.is_action_pressed("run") and not stop_run: 
		if not (not is_aim_locked and is_run_locked): return false
	return true


func handle_toggle_aim() -> void:
	if Input.is_action_just_pressed("aim"):
		is_aiming = !is_aiming


func handle_hold_aim() -> void:
	is_aiming = Input.is_action_pressed("aim")


func switch_aim_state() -> void:
	var default_pos: Vector3 = right_weapon_pos.position if is_right_handed else left_weapon_pos.position
	var target_pos: Vector3 = aim_pos.position if is_aiming else default_pos
	var target_fov: float = ads_fov if is_aiming else default_fov
	var taget_rot: float = (ads_z_rot if is_right_handed else ads_z_rot * -1.0) if is_aiming else 0.0
	var ratio = inverse_lerp(default_pos.x, aim_pos.position.x, weapon_container.position.x)
	var time = time_to_ads * ((1 - ratio) if is_aiming else ratio)
	var in_first: Tween.EaseType = Tween.EASE_IN if is_aiming else Tween.EASE_OUT
	var out_first: Tween.EaseType = Tween.EASE_OUT if is_aiming else Tween.EASE_IN
	if wpn_x_aim_twn:
		wpn_x_aim_twn.kill()
		if wpn_y_aim_twn: wpn_y_aim_twn.kill()
		if wpn_z_aim_twn: wpn_z_aim_twn.kill()
		if fov_aim_twn: fov_aim_twn.kill()
		if cam_rot_aim_twn: cam_rot_aim_twn.kill()
	wpn_x_aim_twn = create_tween()
	wpn_y_aim_twn = create_tween()
	wpn_z_aim_twn = create_tween()
	fov_aim_twn = create_tween()
	wpn_x_aim_twn.tween_property(weapon_container, "position:x", target_pos.x, time).set_trans(Tween.TRANS_SINE).set_ease(out_first)
	wpn_y_aim_twn.tween_property(weapon_container, "position:y", target_pos.y, time).set_trans(Tween.TRANS_QUINT).set_ease(out_first)
	wpn_z_aim_twn.tween_property(weapon_container, "position:z", target_pos.z, time).set_trans(Tween.TRANS_QUINT).set_ease(in_first)
	fov_aim_twn.tween_property(player_camera, "fov", target_fov, time).set_trans(Tween.TRANS_SINE).set_ease(in_first)
	if is_ads_rot_active:
		cam_rot_aim_twn = create_tween()
		cam_rot_aim_twn.tween_property(wpn_cam_base, "rotation_degrees:z", taget_rot, time).set_trans(Tween.TRANS_QUINT).set_ease(in_first)


func capture_run_state() -> void:
	if can_run():
		if is_run_locked: handle_toggle_run()
		else: handle_hold_run()
	else: is_running = false


func can_run() -> bool:
	if is_reloading: return false
	if not is_grounded: return false
	if stop_run: return false
	if is_run_locked and Input.is_action_pressed("aim"): return false
	return true


func handle_toggle_run() -> void:
	if Input.is_action_just_pressed("run"):
		go_for_run()


func handle_hold_run() -> void:
	if Input.is_action_pressed("run"): go_for_run()
	else: is_running = false


func go_for_run() -> void:
	if is_changing_state: return
	if is_crouched: crouch_to_up(false, true)
	elif is_prone: prone_to_up(false, true)
	else: is_running = !is_running if is_run_locked else true


func capture_position_state() -> void:
	if not is_grounded: return
	
	if Input.is_action_just_pressed("reload"):
		pass
	
	if is_changing_state: return
	
	if Input.is_action_just_pressed("crouch"):
		if is_crouched: crouch_to_up()
		elif is_prone: prone_to_crouch()
		else: crouch_to_up(true)
	
	if Input.is_action_just_pressed("prone"):
		if is_crouched: prone_to_crouch(true)
		elif is_prone: prone_to_up()
		else: prone_to_up(true)
	
	if Input.is_action_just_pressed("jump"):
		if is_crouched: crouch_to_up()
		elif is_prone: prone_to_up()
		else: if not is_reloading: jump()


func crouch_to_up(inverse: bool = false, ask_run: bool = false) -> void:
	is_changing_state = true
	is_crouched = inverse
	if inverse: is_running = false
	if ask_run: is_running = true
	var target: float = crouch_height if inverse else standing_height
	state_twn = create_tween()
	state_twn.tween_property(camera_pivot, "position:y", target, state_switch_time)
	await state_twn.finished
	is_changing_state = false


func prone_to_crouch(inverse: bool = false) -> void:
	is_changing_state = true
	is_crouched = not inverse
	is_prone = inverse
	var target: float = prone_height if inverse else crouch_height
	state_twn = create_tween()
	state_twn.tween_property(camera_pivot, "position:y", target, state_switch_time)
	await state_twn.finished
	is_changing_state = false


func prone_to_up(inverse: bool = false, ask_run: bool = false) -> void:
	is_changing_state = true
	is_crouched = true
	if inverse: is_running = false
	var target: float = prone_height if inverse else standing_height
	state_twn = create_tween()
	state_twn.tween_property(camera_pivot, "position:y", crouch_height, state_switch_time)
	await state_twn.finished
	await get_tree().create_timer(0.1).timeout
	is_prone = inverse
	is_crouched = false
	if ask_run: is_running = true
	state_twn = create_tween()
	state_twn.tween_property(camera_pivot, "position:y", target, state_switch_time)
	await state_twn.finished
	is_changing_state = false


func jump() -> void:
	velocity.y = JUMP_VELOCITY


func process_movement(delta: float) -> void:
	apply_plane_movement(delta)
	if not is_on_floor():
		velocity += get_gravity() * delta
	move_and_slide()


func apply_plane_movement(delta: float) -> void:
	var mov_vec: Vector2 = p_inputs.move_vec
	var dir: Vector3 = (transform.basis * Vector3(mov_vec.x, 0, mov_vec.y).normalized())
	var ref_speed = get_used_speed()
	var run_f: float = run_speed_ratio if is_running else 1.0
	var aim_f: float = aiming_speed_ratio if is_aiming else 1.0
	
	var f_speed: float = ref_speed * abs(mov_vec.y)
	if mov_vec.y < 0 : f_speed *= back_speed_ratio
	var s_speed: float = abs(mov_vec.x) * ref_speed * side_speed_ratio
	var dir_speed: float = sqrt(f_speed * f_speed + s_speed * s_speed)
	var applied_speed: float = dir_speed * run_f * aim_f
	
	if not is_grounded:
		var lcl_max: float = standing_speed * (run_speed_ratio if is_running else 1.0)
		if velocity.length() < lcl_max: velocity += dir * ref_speed * delta
		return
	
	if is_movement_smooth:
		var lcl_vel: Vector3 = global_transform.basis.inverse() * velocity
		var lcl_dir: Vector3 = Vector3(mov_vec.x, 0.0, mov_vec.y).normalized()
		var lcl_target_speed: Vector3 = Vector3(lcl_dir.x * applied_speed, 0.0, lcl_dir.z * applied_speed)
		var x_brake_step: float = ref_speed * side_speed_ratio * delta * brake_time_ratio
		var z_brake_step: float = ref_speed * delta * brake_time_ratio

		if lcl_dir.x:
			lcl_vel.x = move_toward(lcl_vel.x, lcl_target_speed.x, abs(lcl_target_speed.x) * delta * acc_time_ratio)
			if sign(lcl_target_speed.x) and sign(lcl_vel.x) != sign(lcl_target_speed.x):
				lcl_vel.x = move_toward(lcl_vel.x, lcl_target_speed.x, abs(lcl_target_speed.x) * delta * acc_time_ratio)
		else:
			lcl_vel.x = move_toward(lcl_vel.x, 0.0, x_brake_step)
		
		if lcl_dir.z:
			lcl_vel.z = move_toward(lcl_vel.z, lcl_target_speed.z, abs(lcl_target_speed.z) * delta * acc_time_ratio)
			if sign(lcl_target_speed.z) and sign(lcl_vel.z) != sign(lcl_target_speed.z):
				lcl_vel.z = move_toward(lcl_vel.z, lcl_target_speed.z, abs(lcl_target_speed.z) * delta * acc_time_ratio)
		else:
			lcl_vel.z = move_toward(lcl_vel.z, 0.0, z_brake_step)
		
		velocity = global_transform.basis * lcl_vel
	else:
		var speed: Vector3 = Vector3(dir.x * applied_speed, 0.0, dir.z * applied_speed)
		velocity = Vector3(speed.x, velocity.y, speed.z) if dir else Vector3(0.0, velocity.y, 0.0)


func get_used_speed() -> float:
	if not is_grounded:
		return air_up_speed
	elif is_crouched:
		return crouch_speed
	elif is_prone:
		return prone_speed
	else:
		return standing_speed


func process_view(delta: float) -> void:
	if not p_inputs.is_mouse_locked(): return
	var inversion: float = -1 if p_inputs.is_inverted else 1
	var reducer: float = (ads_speed_view_reduc if is_aiming else 1.0) * (prone_speed_view_reduc if is_prone else 1.0)
	aim_target.y -= p_inputs.get_view_input().x * p_inputs.h_sensi_multiplier * reducer
	aim_target.x += p_inputs.get_view_input().y * p_inputs.v_sensi_multiplier * inversion * reducer
	var clamp_applied: Vector2 = v_clamp_prone if is_prone else v_clamp_deg
	aim_target.x = clampf(aim_target.x, clamp_applied.x, clamp_applied.y)
	
	if is_aim_smooth:
		var result_y: Dictionary = smooth_damp_angle(rotation_degrees.y, aim_target.y, aim_vel.y, aim_smooth_strength, delta)
		var result_x: Dictionary = smooth_damp_angle(camera_pivot.rotation_degrees.x, aim_target.x, aim_vel.x, aim_smooth_strength, delta)
		rotation_degrees.y = result_y.value
		camera_pivot.rotation_degrees.x = result_x.value
		aim_vel.y = result_y.velocity
		aim_vel.x = result_x.velocity
	else:
		rotation_degrees.y = aim_target.y
		camera_pivot.rotation_degrees.x = aim_target.x


func smooth_damp_angle(current: float, target: float, current_velocity: float, smooth_strength: float, delta: float) -> Dictionary:
	target = current + wrapf(target - current, -180.0, 180.0)
	return smooth_damp(current, target, current_velocity, smooth_strength, delta)


func smooth_damp(current: float, target: float, current_velocity: float, smooth_strength: float, delta: float) -> Dictionary:
	smooth_strength = max(smooth_strength, 0.0001)
	var omega: float = 2.0 / smooth_strength
	var x: float = omega * delta
	var expo: float = 1.0 / (1.0 + x + (0.48 * x * x) + (0.235 * x * x * x))
	var change: float = current - target
	var temp: float = (current_velocity + omega * change) * delta
	var new_velocity: float = (current_velocity - omega * temp) * expo
	var output: float = target + (change + temp) * expo
	return { "value": output, "velocity": new_velocity }


func handle_weapon_movement(delta: float) -> void:
	if not has_weapon: return
	handle_weapon_sway(delta)
	handle_weapon_lag(delta)


func handle_weapon_sway(delta: float) -> void:
	set_ads_sway_len_by_state()
	set_ads_sway_freq(delta)
	apply_ads_sway()


func set_ads_sway_len_by_state() -> void:
	var reducer: float = prone_sway_reduc if is_prone else (crouch_sway_reduc if is_crouched else 1.0)
	var sway_target: Vector2 = Vector2(sway_pitch_len, sway_yaw_len) * reducer
	var noise_target: float = sway_noise_len * reducer
	curr_sway_len.x = move_toward(curr_sway_len.x, sway_target.x, 0.005)
	curr_sway_len.y = move_toward(curr_sway_len.y, sway_target.y, 0.005)
	curr_sway_noise_len = move_toward(curr_sway_noise_len, noise_target, 0.005)


func set_ads_sway_freq(delta: float) -> void:
	ads_timer += delta
	if not is_aiming: ads_timer = 0.0
	concentration_sample = ads_concentration_curve.sample(ads_timer)
	sway_timer += delta * concentration_sample
	if ads_timer >= time_to_ads:
		var fov_diff: float = ads_fov - perfect_fov
		var fov_target: float = ads_fov - (fov_diff * (1 - concentration_sample))
		player_camera.fov = lerp(player_camera.fov, fov_target, dt_lerp_t(10.0, delta))


func dt_lerp_t(speed: float, delta: float) -> float:
	return 1.0 - exp(-speed * delta)


func apply_ads_sway() -> void:
	var pitch: float = cos(sway_timer * sway_x_freq) * curr_sway_len.x
	pitch += aim_noise_y.get_noise_1d(sway_timer * sway_noise_freq) * curr_sway_noise_len
	var yaw: float = sin(sway_timer * sway_y_freq) * curr_sway_len.y
	yaw += aim_noise_x.get_noise_1d(sway_timer * sway_noise_freq) * curr_sway_noise_len
	weapon_sway_root.rotation_degrees.x = pitch
	weapon_sway_root.rotation_degrees.y = yaw


func handle_weapon_lag(delta: float) -> void:
	set_weapon_lag_parameters()
	apply_weapon_pos_lag(delta)
	if is_aiming: apply_weapon_rot_lag(delta)


func set_weapon_lag_parameters() -> void:
	var root_pos_dist: float = (weapon_container.global_position - weapon_lag_root.global_position).length()
	var targ_pos_dist: float = (weapon_container.global_position - lag_target.global_position).length()
	applied_pos_lag_speed = wp_pos_lag_close_speed if (root_pos_dist > targ_pos_dist) else wp_pos_lag_away_speed
	var root_rot_dist: float = abs(angle_difference(weapon_container.global_rotation.y, weapon_lag_root.global_rotation.y))
	var targ_rot_dist: float = abs(angle_difference(weapon_container.global_rotation.y, lag_target.global_rotation.y))
	applied_rot_lag_speed = wp_rot_lag_close_speed if (root_rot_dist > targ_rot_dist) else wp_rot_lag_away_speed


func apply_weapon_pos_lag(delta: float) -> void:
	var f_targ: Vector3 = weapon_container.global_position
	var dist: Vector3 = lag_target.global_position - f_targ
	var dist_xz: Vector3 = Vector3(dist.x, 0.0, dist.z)
	var dist_y: Vector3 = Vector3(0.0, dist.y, 0.0)
	var max_xz = max_wp_xz_pos_lag * concentration_sample * (ads_wp_pos_lag_reducer if is_aiming else 1.0)
	var max_y = max_wp_y_pos_lag * concentration_sample
	
	if dist_xz.length() >= max_xz:
		var dir_xz: Vector3 = dist_xz.normalized()
		var new_xz: Vector3 = f_targ + (dir_xz * max_xz)
		lag_target.global_position = Vector3(new_xz.x, lag_target.global_position.y, new_xz.z)
	
	if dist_y.length() >= max_y:
		var dir_y: Vector3 = dist_y.normalized()
		var new_y: Vector3 = f_targ + (dir_y * max_y)
		lag_target.global_position.y = new_y.y
	
	lag_target.global_position = lag_target.global_position.lerp(f_targ, dt_lerp_t(wp_pos_lag_close_speed, delta))
	var s_targ: Vector3 = weapon_container.to_local(lag_target.global_position)
	weapon_lag_root.position = weapon_lag_root.position.lerp(s_targ, dt_lerp_t(applied_pos_lag_speed, delta))


func apply_weapon_rot_lag(delta: float) -> void:
	var f_targ: Vector3 = weapon_container.global_rotation
	var y_diff: float = angle_difference(f_targ.y, lag_target.global_rotation.y)
	var x_diff: float = angle_difference(f_targ.x, lag_target.global_rotation.x)
	var max_y: float = max_wp_y_rot_lag_deg * concentration_sample
	var max_x: float = max_wp_x_rot_lag_deg * concentration_sample
	
	if abs(y_diff) >= deg_to_rad(max_y):
		lag_target.global_rotation.y = f_targ.y + (deg_to_rad(max_y) * sign(y_diff))
	
	if abs(x_diff) >= deg_to_rad(max_x):
		lag_target.global_rotation.x = f_targ.x + (deg_to_rad(max_x) * sign(x_diff))
	
	lag_target.global_rotation = lerp_rot(lag_target.global_rotation,f_targ, dt_lerp_t(wp_rot_lag_close_speed, delta))
	var parent_q: Quaternion = weapon_container.global_basis.get_rotation_quaternion()
	var target_q: Quaternion = lag_target.global_basis.get_rotation_quaternion()
	var local_q: Quaternion = parent_q.inverse() * target_q
	var s_targ: Vector3 = -local_q.get_euler()
	weapon_lag_root.rotation = lerp_rot(weapon_lag_root.rotation, s_targ, dt_lerp_t(applied_rot_lag_speed, delta))


func lerp_rot(a: Vector3, b: Vector3, t: float) -> Vector3:
	return Vector3( lerp_angle(a.x, b.x, t), lerp_angle(a.y, b.y, t), lerp_angle(a.z, b.z, t))


func handle_shoot() -> void:
	if not can_use_shoot() : return
	if Input.is_action_just_pressed("shoot"):
		is_weapon_loaded = false
		handle_shoot_cast()


func can_use_shoot() -> bool:
	if not p_inputs.is_mouse_locked() : return false
	if not has_weapon: return false
	if not is_weapon_loaded: return false
	if not can_shoot: return false
	return true


func handle_shoot_cast() -> void:
	var obj: Object = weapon_ray_cast.get_collider()
	if not obj or (obj is not Agent and obj is not ShootTarget):
		print("MISS !")
		return
	if obj is Agent:
		obj.die()
		if obj.team == Agent.Team.COMMUNARD:
			print("Communard touched !")
			return
		print("Versaillais touched !")
	elif obj is ShootTarget:
		if obj.is_ally:
			print("Communard touched !")
			return
		print("Versaillais touched !")


func handle_reload() -> void:
	capture_begin_reload()


func capture_begin_reload() -> void:
	if not can_reload(): return
	if Input.is_action_just_pressed("reload"):
		enter_reload()


func can_reload() -> bool:
	if not p_inputs.is_mouse_locked() : return false
	if not has_weapon: return false
	if is_reloading: return false
	if is_weapon_loaded: return false
	return true


func enter_reload() -> void:
	is_reloading = true
	if is_aiming: await get_tree().create_timer(time_to_ads).timeout
	var t: Tween = create_tween()
	await t.tween_property(weapon_container, "rotation_degrees:x", 25.0, 0.5
					).set_trans(Tween.TRANS_QUART).set_ease(Tween.EaseType.EASE_OUT).finished
	reload_ui.activation(true)
	reload_ui.reloaded.connect(on_reloaded, CONNECT_ONE_SHOT)


func on_reloaded() -> void:
	exit_reload()


func exit_reload() -> void:
	var t: Tween = create_tween()
	await t.tween_property(weapon_container, "rotation_degrees:x", 0.0, 0.5
					).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EaseType.EASE_IN).finished
	is_reloading = false
	is_weapon_loaded = true
