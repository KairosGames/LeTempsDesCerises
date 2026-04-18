class_name Player extends CharacterBody3D

@onready var p_inputs: PlayerInputs = %PlayerInputs
@onready var camera_pivot: Node3D = %CameraPivot
@onready var wpn_cam_base: Node3D = %WeaponCameraBase
@onready var player_camera: Camera3D = %PlayerCamera
@onready var weapon_container: Node3D = %WeaponContainer
@onready var right_weapon_pos: Marker3D = %RightWeaponPos
@onready var left_weapon_pos: Marker3D = %LeftWeaponPos
@onready var aim_pos: Marker3D = %AimPos
@onready var weapon_root: Node3D = %WeaponRoot
@onready var weapon_ray_cast: RayCast3D = %WeaponRayCast

@export_category("Exposed settings")
@export var is_aim_locked: bool = true
@export var is_run_lock: bool = true
@export var is_position_switcher_locked: bool = true
@export var is_aim_smooth: bool = true
@export var is_movement_smooth: bool = true

@export_category("Character settings")
@export var is_right_handed: bool = true

@export_category("View settings")
@export var v_clamp_deg: Vector2 = Vector2(-70.0, 70.0)
@export var v_clamp_lyingd: Vector2 = Vector2(-45.0, 45.0)
@export_range(0.01, 1.0, 0.01) var ads_speed_view_reduc: float = 0.4
@export_range(0.1, 1.0, 0.01) var lyingd_speed_view_reduc: float = 0.3

@export_category("ADS settings")
@export var default_fov: float = 75.0
@export var ads_fov: float = 65.0
@export var perfect_fov: float = 59.0
@export var time_to_ads: float = 0.4
@export var is_ads_rot_active: bool = false
@export var ads_z_rot: float = 1.0

@export_category("ADS sway settings")
@export var ads_sway_pitch_len: float = 1.35
@export var ads_sway_yaw_len: float = 1.0
@export var ads_crouch_sway_reduc: float = 0.6
@export var ads_lyingd_sway_reduc: float = 0.2
@export var ads_sway_x_freq: float = 1.0
@export var ads_sway_y_freq: float = 0.85
@export var ads_noise_len: float = 1.25
@export var ads_noise_freq: float = 2.5
@export var ads_sway_evolution_curve: Curve

@export_category("Shoot settings")
@export var reload_time: float = 7.0

@export_category("States settings")
@export var state_switch_time: float = 0.2
@export var standing_height: float = 1.6
@export var crouch_height: float = 1.1
@export var lyingd_height: float = 0.35
@export_range(0.2, 1.0, 0.01) var gpad_mini_run_length: float = 0.5

@export_category("Movement speed settings")
@export var standing_speed: float = 5.0
@export var crouch_speed: float = 3.0
@export var lying_d_speed: float = 1.0
@export_range(0.0, 1.0, 0.01) var air_up_speed: float = 1.0
@export_range(1.0, 3.0, 0.01) var run_speed_ratio: float = 1.5
@export_range(0.0, 1.0, 0.01) var side_speed_ratio: float = 0.75
@export_range(0.0, 1.0, 0.01) var back_speed_ratio: float = 0.6
@export_range(0.0, 1.0, 0.01) var aiming_speed_ratio: float = 0.3

@export_category("Smoothness settings")
@export_range(0.01, 0.5, 0.01) var acc_time: float = 0.1
@export_range(0.01, 0.5, 0.01) var brake_time: float = 0.1
@export_range(0.01, 1.0, 0.001) var aim_smooth_strength: float = 0.05

var aim_noise_x: FastNoiseLite = FastNoiseLite.new()
var aim_noise_y: FastNoiseLite = FastNoiseLite.new()
var aim_vel: Vector3 = Vector3.ZERO
var aim_target: Vector3 = Vector3.ZERO
var curr_ads_sway_len: Vector2
#var curr_ads_sway_freq: Vector2
var curr_ads_noise_len: float
#var curr_ads_noise_freq: float
var acc_time_ratio: float
var brake_time_ratio: float
var sway_timer: float
var ads_timer: float

var is_grounded: bool = true
var is_aiming: bool = false
var is_running: bool = false
var is_crouched:bool = false
var is_lyingd: bool = false
var is_changing_state: bool = false
var stop_run: bool = false
var can_shoot: bool = true
var is_reloading: bool = false

var wpn_x_aim_twn: Tween
var wpn_y_aim_twn: Tween
var wpn_z_aim_twn: Tween
var fov_aim_twn: Tween
var cam_rot_aim_twn: Tween
var state_twn: Tween

const JUMP_VELOCITY = 4.5


func _ready() -> void:
	weapon_container.position = right_weapon_pos.position if is_right_handed else left_weapon_pos.position
	aim_target = Vector3(camera_pivot.rotation_degrees.x, rotation_degrees.y, 0.0)
	acc_time_ratio = (1 / acc_time)
	brake_time_ratio = (1 / brake_time)
	aim_noise_x.seed = randi()
	aim_noise_x.seed = randi()
	curr_ads_sway_len = Vector2(ads_sway_pitch_len, ads_sway_yaw_len)
	curr_ads_noise_len = ads_noise_len


func _process(delta: float) -> void:
	capture_states()
	process_movement(delta)
	process_view(delta)
	handle_weapon_movement(delta)
	handle_shoot()


func capture_states() -> void:
	is_grounded = is_on_floor()
	if not p_inputs.is_mouse_locked(): return
	capture_aim_state()
	capture_position_state()


func capture_aim_state() -> void:
	if is_reloading: return
	var flag: bool = is_aiming
	if is_aim_locked:
		if Input.is_action_just_pressed("aim"):
			is_aiming = !is_aiming
			is_running = false
	else:
		is_aiming = Input.is_action_pressed("aim")
		if is_aiming: is_running = false
	if ((Input.is_action_just_pressed("run") and not stop_run) or Input.is_action_just_pressed("jump")) and is_aiming:
		is_aiming = false
	p_inputs.is_aiming = is_aiming
	if flag != is_aiming :
		switch_aim_state()


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


func capture_position_state() -> void:
	var input_dir: Vector2 = p_inputs.move_vec
	stop_run = input_dir.y <= 0.0 or abs(input_dir.x) > 0.71 or input_dir.length() < gpad_mini_run_length
	if stop_run: is_running = false
	
	if not is_grounded or is_changing_state: return
	
	if Input.is_action_just_pressed("crouch"):
		if is_crouched: crouch_to_up()
		elif is_lyingd: lyingd_to_crouch()
		else: crouch_to_up(true)
	
	if Input.is_action_just_pressed("lying_down"):
		if is_crouched: lyingd_to_crouch(true)
		elif is_lyingd: lyingd_to_up()
		else: lyingd_to_up(true)
	
	if Input.is_action_just_pressed("run") and not stop_run:
		if is_crouched: crouch_to_up(false, true)
		elif is_lyingd: lyingd_to_up(false, true)
		else: is_running = true
	
	if Input.is_action_just_pressed("jump"):
		if is_crouched: crouch_to_up()
		elif is_lyingd: lyingd_to_up()
		else: jump()


func crouch_to_up(inverse: bool = false, ask_run: bool = false):
	is_changing_state = true
	is_crouched = inverse
	if inverse: is_running = false
	if ask_run: is_running = true
	var target: float = crouch_height if inverse else standing_height
	state_twn = create_tween()
	state_twn.tween_property(camera_pivot, "position:y", target, state_switch_time)
	await state_twn.finished
	is_changing_state = false


func lyingd_to_crouch(inverse: bool = false):
	is_changing_state = true
	is_crouched = not inverse
	is_lyingd = inverse
	var target: float = lyingd_height if inverse else crouch_height
	state_twn = create_tween()
	state_twn.tween_property(camera_pivot, "position:y", target, state_switch_time)
	await state_twn.finished
	is_changing_state = false


func lyingd_to_up(inverse: bool = false, ask_run: bool = false):
	is_changing_state = true
	is_crouched = true
	if inverse: is_running = false
	var target: float = lyingd_height if inverse else standing_height
	state_twn = create_tween()
	state_twn.tween_property(camera_pivot, "position:y", crouch_height, state_switch_time)
	await state_twn.finished
	await get_tree().create_timer(0.1).timeout
	is_lyingd = inverse
	is_crouched = false
	if ask_run: is_running = true
	state_twn = create_tween()
	state_twn.tween_property(camera_pivot, "position:y", target, state_switch_time)
	await state_twn.finished
	is_changing_state = false


func jump():
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
		var max: float = standing_speed * (run_speed_ratio if is_running else 1.0)
		if velocity.length() < max: velocity += dir * ref_speed * delta
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
	elif is_lyingd:
		return lying_d_speed
	else:
		return standing_speed


func process_view(delta: float) -> void:
	if not p_inputs.is_mouse_locked(): return
	var inversion: float = -1 if p_inputs.is_inverted else 1
	var reducer: float = (ads_speed_view_reduc if is_aiming else 1.0) * (lyingd_speed_view_reduc if is_lyingd else 1.0)
	aim_target.y -= p_inputs.get_view_input().x * p_inputs.h_sensi_multiplier * reducer
	aim_target.x += p_inputs.get_view_input().y * p_inputs.v_sensi_multiplier * inversion * reducer
	var clamp_applied: Vector2 = v_clamp_lyingd if is_lyingd else v_clamp_deg
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
	set_ads_sway_len_by_state()
	set_ads_sway_freq(delta)
	apply_ads_sway()


func set_ads_sway_len_by_state() -> void:
	var reducer: float = ads_lyingd_sway_reduc if is_lyingd else (ads_crouch_sway_reduc if is_crouched else 1.0)
	var sway_target: Vector2 = Vector2(ads_sway_pitch_len, ads_sway_yaw_len) * reducer
	var noise_target: float = ads_noise_len * reducer
	curr_ads_sway_len.x = move_toward(curr_ads_sway_len.x, sway_target.x, 0.005)
	curr_ads_sway_len.y = move_toward(curr_ads_sway_len.y, sway_target.y, 0.005)
	curr_ads_noise_len = move_toward(curr_ads_noise_len, noise_target, 0.005)


func set_ads_sway_freq(delta: float):
	ads_timer += delta
	if not is_aiming: ads_timer = 0.0
	var freq_reduc: float = ads_sway_evolution_curve.sample(ads_timer)
	sway_timer += delta * freq_reduc
	if ads_timer >= time_to_ads:
		var fov_diff: float = ads_fov - perfect_fov
		var fov_target: float = ads_fov - (fov_diff * (1 - freq_reduc))
		player_camera.fov = lerp(player_camera.fov, fov_target, 0.1)


func apply_ads_sway():
	var pitch: float = cos(sway_timer * ads_sway_x_freq) * curr_ads_sway_len.x
	pitch += aim_noise_y.get_noise_1d(sway_timer * ads_noise_freq) * curr_ads_noise_len
	var yaw: float = sin(sway_timer * ads_sway_y_freq) * curr_ads_sway_len.y
	yaw += aim_noise_x.get_noise_1d(sway_timer * ads_noise_freq) * curr_ads_noise_len
	weapon_root.rotation_degrees.x = pitch
	weapon_root.rotation_degrees.y = yaw


func handle_shoot() -> void:
	if not Input.is_action_just_pressed("shoot") or not can_shoot or not p_inputs.is_mouse_locked():
		return
	can_shoot = false
	handle_shoot_cast()
	reload()


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


func reload() -> void:
	is_reloading = true
	if is_aiming:
		is_aiming = false
		switch_aim_state()
	await get_tree().create_timer(time_to_ads).timeout
	var t: Tween = create_tween()
	await t.tween_property(weapon_container, "rotation_degrees:x", 25.0, 0.8
					).set_trans(Tween.TRANS_QUART).set_ease(Tween.EaseType.EASE_OUT).finished
	await get_tree().create_timer(reload_time - ((time_to_ads * 2) + 0.8)).timeout
	t = create_tween()
	await t.tween_property(weapon_container, "rotation_degrees:x", 0.0, time_to_ads
					).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EaseType.EASE_IN).finished
	is_reloading = false
	can_shoot = true
