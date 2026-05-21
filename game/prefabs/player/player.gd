class_name Player extends CharacterBody3D

signal missed_by_enemy
signal died

@onready var p_inputs: PlayerInputs = %PlayerInputs
@onready var reload_ui: ReloadUI = %ReloadUI
@onready var camera_pivot: Node3D = %CameraPivot
@onready var wpn_cam_base: Node3D = %WeaponCameraBase
@onready var player_camera: Camera3D = %PlayerCamera
@onready var weapon_camera: Camera3D = %WeaponCamera
@onready var weapon_container: Node3D = %WeaponContainer
@onready var right_weapon_pos: Marker3D = %RightWeaponPos
@onready var left_weapon_pos: Marker3D = %LeftWeaponPos
@onready var aim_pos: Marker3D = %AimPos
@onready var weapon_sway_root: Node3D = %WeaponSwayRoot
@onready var weapon_lag_root: Node3D = %WeaponLagRoot
@onready var lag_target: Node3D = %LagTarget
@onready var weapon_ray_cast: RayCast3D = %WeaponRayCast
@onready var high_collider: CollisionShape3D = %HighDynamicCollider
@onready var low_collider: CollisionShape3D = %LowDynamicCollider
@onready var sub_wpn_container: Node3D = %SubWeaponContainer
@onready var pull_back_cast: RayCast3D = %PullBackCast
@onready var pull_back_marker_right: Marker3D = %RightPullBackPosture
@onready var pull_back_marker_left: Marker3D = %LeftPullBackPosture
@onready var weapon_bob_root: Node3D = %WeaponBobRoot

@export_category("Exposed settings")
@export var is_aim_toggle_km: bool = true
@export var is_run_toggle_km: bool = false
@export var is_aim_toggle_gpad: bool = false
@export var is_run_toggle_gpad: bool = true
@export var is_posture_switch_toggle_km: bool = true
@export var is_aim_smooth: bool = true
@export var is_movement_smooth: bool = true

@export_category("Character settings")
@export var is_right_handed: bool = true
@export var has_weapon: bool = true
@export var shoot_targets: Array[Marker3D]

@export_category("View settings")
@export var v_clamp_deg: Vector2 = Vector2(-70.0, 85.0)
@export var v_clamp_prone: Vector2 = Vector2(-30.0, 20.0)
@export_range(0.01, 1.0, 0.01) var ads_speed_view_reduc: float = 0.4
@export_range(0.1, 1.0, 0.01) var prone_speed_view_reduc: float = 0.3

@export_category("FOV settings")
@export var default_fov: float = 75.0
@export var ads_fov: float = 65.0
@export var perfect_fov: float = 55.0
@export var run_fov: float = 78.0
@export var weapon_fov_diff: float = 0.0
@export var is_run_fov_active: bool = true

@export_category("ADS settings")
@export var time_to_ads: float = 0.4
@export var is_ads_rot_active: bool = true
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
@export var max_wpn_xz_pos_lag: float = 0.015
@export var max_wpn_y_pos_lag: float = 0.003
@export var wpn_pos_lag_away_speed: float = 2.5
@export var wpn_pos_lag_close_speed: float = 5.0
@export var ads_wpn_pos_lag_reducer: float = 0.30
@export var max_wpn_pitch_lag_deg: float = 0.2
@export var max_wpn_yaw_lag_deg: float = 20.0
@export var wpn_rot_lag_away_speed: float = 1.0
@export var wpn_rot_lag_close_speed: float = 5.0
@export var max_wpn_roll_lag_from_move_deg: float = 10.0
@export var max_wpn_roll_lag_from_view_deg: float = 6.0

@export_category("Weapon pull back settings")
@export var pull_back_timer: float = 0.2
@export var pull_back_default_dist: float = 0.9
@export var pull_back_aim_dist: float = 0.5
@export var pull_back_reload_dist: float = 0.35

@export_category("Weapon bob settings")
@export var walk_bob_pos: Vector3 = Vector3(0.006, 0.010, 0.004)
@export var crouch_bob_pos: Vector3 = Vector3(0.010, 0.018, 0.008)
@export var prone_bob_pos: Vector3 = Vector3(0.025, -0.03, 0.025)
@export var run_bob_pos: Vector3 = Vector3(0.014, 0.022, 0.010)
@export var walk_bob_rot_deg: Vector3 = Vector3(0.5, 0.35, 0.8)
@export var crouch_bob_rot_deg: Vector3 = Vector3(0.9, 0.45, 1.4)
@export var prone_bob_rot_deg: Vector3 = Vector3(7.0, 5.0, 9.0)
@export var run_bob_rot_deg: Vector3 = Vector3(1.1, 0.7, 1.8)
@export var walk_bob_freq: float = 6.0
@export var run_bob_freq: float = 21.0
@export var crouch_bob_freq_factor: float = 0.8
@export var prone_bob_freq_factor: float = 2.5
@export_range(0.0, 1.0, 0.01) var ads_bob_freq_factor: float = 2.0
@export_range(0.0, 1.0, 0.01) var ads_bob_amp_factor: float = 0.3
@export_range(0.0, 1.0, 0.01) var pull_bob_freq_factor: float = 0.5
@export var bob_default_smooth_speed: float = 10.0
@export var bob_run_smooth_speed: float = 50.0

@export_category("Recoil settings")
@export var recoil_strength: float = 7.0
@export var recoil_time: float = 0.1
@export var time_to_return_from_recoil: float = 1.0

@export_category("States settings")
@export var state_switch_time: float = 0.2
@export var stand_height: float = 1.6
@export var crouch_height: float = 1.1
@export var prone_height: float = 0.35
@export_range(0.2, 1.0, 0.01) var gpad_mini_run_length: float = 0.5

@export_category("Movement speed settings")
@export var stand_speed: float = 4.0
@export var crouch_speed: float = 2.5
@export var prone_speed: float = 1.0
@export_range(0.0, 1.0, 0.01) var air_up_speed: float = 1.0
@export_range(1.0, 3.0, 0.01) var run_speed_ratio: float = 2.0
@export_range(0.0, 1.0, 0.01) var side_speed_ratio: float = 0.75
@export_range(0.0, 1.0, 0.01) var back_speed_ratio: float = 0.6
@export_range(0.0, 1.0, 0.01) var aiming_speed_ratio: float = 0.3

@export_category("Air settings")
@export var is_jump_possible: bool = true
@export var jump_strength = 4.5
@export var gravity_multiplier = 2.0

@export_category("Smoothness settings")
@export_range(0.01, 0.5, 0.01) var acc_time: float = 0.1
@export_range(0.01, 0.5, 0.01) var brake_time: float = 0.1
@export_range(0.01, 1.0, 0.001) var aim_smooth_strength: float = 0.05

enum Posture { STAND, CROUCH, PRONE }
var curr_posture: Posture = Posture.STAND
var is_changing_state: bool = false
var was_it_just_prone_gpad: bool

var high_capsule_shape: CapsuleShape3D
var low_capsule_shape: CapsuleShape3D
var height_above_eyes: float
var min_capsule_radius: float

var is_aim_toggle: bool
var is_run_toggle: bool
var is_posture_switch_toggle: bool

var is_grounded: bool = true
var stop_run: bool = false
var is_moving_side: bool = false
var is_aiming: bool = false
var is_running: bool = false
var wait_aim_release: bool = false
var wait_run_release: bool = false

var can_shoot: bool = true
var is_weapon_loaded: bool = true
var is_reloading: bool = false
var is_pulling_back: bool = false
var is_reload_interruped: bool = false
var is_alive: bool = true
var can_play: bool = true

var aim_noise_x: FastNoiseLite = FastNoiseLite.new()
var aim_noise_y: FastNoiseLite = FastNoiseLite.new()
var curr_sway_len: Vector2
var curr_sway_noise_len: float
var sway_timer: float
var ads_timer: float
var concentration_sample: float

var weapon_lag_root_base_pos: Vector3
var applied_pos_lag_speed: float
var applied_rot_lag_speed: float
var recoil_offset: float = 0.0

var aim_vel: Vector3 = Vector3.ZERO
var aim_target: Vector3 = Vector3.ZERO
var local_velocity: Vector3
var acc_time_ratio: float
var brake_time_ratio: float
var view_yaw_speed: float = 0.0
var prev_view_yaw: float = 0.0

var weapon_bob_base_pos: Vector3
var bob_timer: float = 0.0
var bob_amount: float = 0.0
var bob_phase: float

var wpn_x_aim_twn: Tween
var wpn_y_aim_twn: Tween
var wpn_z_aim_twn: Tween
var fov_aim_twn: Tween
var cam_rot_aim_twn: Tween
var state_twn: Tween
var recoil_twn:Tween
var reload_twn: Tween
var pull_back_pos_twn: Tween
var pull_back_rot_twn: Tween


static var instance: Player:
	set(value):
		if not instance: instance = value
		else: push_error("MORE THAN ONE PLAYER IN SCENE")


func _ready() -> void:
	instance = self
	p_inputs.gpad_crouch_pressed.connect(crouch_pressed_from_gpad)
	p_inputs.gpad_crouch_released.connect(crouch_released_from_gpad)
	p_inputs.gpad_ask_prone.connect(prone_from_gpad)
	aim_target = Vector3(camera_pivot.rotation_degrees.x, rotation_degrees.y, 0.0)
	acc_time_ratio = (1 / acc_time)
	brake_time_ratio = (1 / brake_time)
	aim_noise_x.seed = randi()
	aim_noise_y.seed = randi()
	curr_sway_len = Vector2(sway_pitch_len, sway_yaw_len)
	curr_sway_noise_len = sway_noise_len
	weapon_lag_root_base_pos = weapon_lag_root.position
	weapon_bob_base_pos = weapon_bob_root.position
	prev_view_yaw = rotation.y
	high_capsule_shape = high_collider.shape as CapsuleShape3D
	low_capsule_shape = low_collider.shape as CapsuleShape3D
	height_above_eyes = high_capsule_shape.height - stand_height
	min_capsule_radius = high_capsule_shape.radius
	initiate(global_position, global_rotation, has_weapon, is_weapon_loaded, Posture.STAND, is_right_handed)



func _process(delta: float) -> void:
	set_context(delta)
	set_dynamic_collider()
	capture_states()
	process_movement(delta)
	capture_jump()
	handle_weapon_movement(delta)
	handle_shoot()
	handle_reload()
	late_process(delta)

	if Input.is_action_just_pressed("TEST"):
		if is_alive: die()


func initiate(pos: Vector3,
				rot: Vector3,
				h_weapon: bool = true,
				wpn_loaded: bool = true,
				posture: Posture = Posture.STAND,
				right_handed: bool = true) -> void:
	global_position = pos
	global_rotation = rot
	is_right_handed = right_handed
	curr_posture = posture
	match posture:
		Posture.STAND: camera_pivot.position.y = stand_height
		Posture.CROUCH: camera_pivot.position.y = crouch_height
		Posture.PRONE: camera_pivot.position.y = prone_height
	weapon_container.position = right_weapon_pos.position if is_right_handed else left_weapon_pos.position
	has_weapon = h_weapon
	weapon_sway_root.visible = h_weapon
	is_alive = true
	can_play = true
	is_weapon_loaded = wpn_loaded
	synchronise_after_pop()


func late_process(delta: float) -> void:
	process_view(delta)
	handle_camera_effects(delta)


func set_context(delta: float) -> void:
	is_grounded = is_on_floor()
	set_input_context()
	var input_dir: Vector2 = p_inputs.move_vec
	stop_run = input_dir.y <= 0.0 or abs(input_dir.x) > 0.71 or input_dir.length() < gpad_mini_run_length
	is_moving_side = abs(input_dir.x) > 0.70
	local_velocity = global_basis.inverse() * velocity
	view_yaw_speed = angle_difference(prev_view_yaw, rotation.y) / delta
	prev_view_yaw = rotation.y
	if Input.is_action_just_released("run"): wait_run_release = false
	if Input.is_action_just_released("aim"): wait_aim_release = false
	if not is_alive: can_play = false
	var pb_targ: float = pull_back_reload_dist if is_reloading else (pull_back_aim_dist if is_aiming else pull_back_default_dist)
	pull_back_cast.target_position.z = pb_targ


func set_input_context() -> void:
	if p_inputs.is_gamepad:
		is_aim_toggle = is_aim_toggle_gpad
		is_run_toggle = is_run_toggle_gpad
		is_posture_switch_toggle = true
		return
	is_posture_switch_toggle = is_posture_switch_toggle_km
	is_aim_toggle = is_aim_toggle_km
	is_run_toggle = is_run_toggle_km


func set_dynamic_collider() -> void:
	high_collider.position.y = high_capsule_shape.height / 2.0
	low_collider.position.z = min_capsule_radius - (low_capsule_shape.height / 2.0)
	low_collider.disabled = camera_pivot.position.y > min_capsule_radius * 2.0
	high_collider.disabled = !low_collider.disabled
	if low_collider.disabled:
		high_capsule_shape.height = camera_pivot.position.y + height_above_eyes
		high_capsule_shape.radius = min_capsule_radius
		return
	var d: float = min_capsule_radius * 2.0
	low_capsule_shape.height = d + ((d - camera_pivot.position.y) * 2.5)


func capture_states() -> void:
	if not p_inputs.is_mouse_locked(): return
	if not can_play: return
	capture_aim_state()
	capture_run_state()
	capture_position_state()


func capture_aim_state() -> void:
	var was_aiming: bool = is_aiming

	if can_aim():
		if is_aim_toggle: handle_toggle_aim()
		else : handle_hold_aim()
	else : is_aiming = false

	p_inputs.is_aiming = is_aiming
	if was_aiming != is_aiming :
		switch_aim_state()


func can_aim() -> bool:
	if not has_weapon: return false
	if is_pulling_back and not is_running: return false
	if is_reloading: return false
	if not is_grounded: return false
	return true


func handle_toggle_aim() -> void:
	if is_run_toggle:
		if Input.is_action_just_pressed("aim"):
			is_aiming = !is_aiming
			is_running = false
		elif Input.is_action_just_pressed("run"): is_aiming = false
		return

	if Input.is_action_just_pressed("aim"):
		is_aiming = !is_aiming
		if Input.is_action_pressed("run"): wait_run_release = is_aiming
	if is_running and is_aiming and not wait_run_release: is_aiming = false


func handle_hold_aim() -> void:
	if is_run_toggle:
		is_aiming = Input.is_action_pressed("aim") and not wait_aim_release
		if is_aiming: is_running = false
		return

	is_aiming = Input.is_action_pressed("aim") and not wait_aim_release
	if is_aiming and is_running: wait_run_release = true
	elif not is_aiming and Input.is_action_pressed("run"): wait_run_release = false


func switch_aim_state() -> void:
	var default_pos: Vector3 = right_weapon_pos.position if is_right_handed else left_weapon_pos.position
	var target_pos: Vector3 = aim_pos.position if is_aiming else default_pos
	var target_fov: float = ads_fov if is_aiming else default_fov
	var taget_rot: float = (ads_z_rot if is_right_handed else ads_z_rot * -1.0) if is_aiming else 0.0
	var ratio: float = inverse_lerp(default_pos.x, aim_pos.position.x, weapon_container.position.x)
	var time: float = time_to_ads * ((1 - ratio) if is_aiming else ratio)
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
		if is_run_toggle: handle_toggle_run()
		else: handle_hold_run()
	else: is_running = false


func can_run() -> bool:
	if not is_grounded: return false
	if stop_run: return false
	return true


func handle_toggle_run() -> void:
	if is_aim_toggle:
		if Input.is_action_just_pressed("run"): go_for_run()
		return

	if Input.is_action_just_pressed("run"):
		go_for_run()
		if is_aiming: wait_aim_release = true
		if not is_running and Input.is_action_pressed("aim"): wait_aim_release = false


func handle_hold_run() -> void:
	if is_aim_toggle:
		if Input.is_action_pressed("run") and not wait_run_release: go_for_run()
		else: is_running = false
		return

	if Input.is_action_pressed("run") and not wait_run_release:
		go_for_run()
		if is_aiming: wait_aim_release = true
		return
	is_running = false
	if Input.is_action_pressed("aim"): wait_aim_release = false


func go_for_run() -> void:
	if is_changing_state: return
	match curr_posture:
		Posture.STAND: is_running = !is_running if is_run_toggle else true
		Posture.CROUCH: crouch_to_stand(false, true)
		Posture.PRONE: prone_to_up(false, true)


func capture_position_state() -> void:
	if not is_grounded or is_changing_state: return

	if Input.is_action_just_pressed("crouch"):
		if p_inputs.is_gamepad: return
		match curr_posture:
			Posture.STAND:crouch_to_stand(true)
			Posture.CROUCH: crouch_to_stand()
			Posture.PRONE: prone_to_crouch()

	if Input.is_action_just_pressed("prone"):
		if p_inputs.is_gamepad: return
		match curr_posture:
			Posture.STAND: prone_to_up(true)
			Posture.CROUCH: prone_to_crouch(true)
			Posture.PRONE: prone_to_up()


func crouch_to_stand(inverse: bool = false, ask_run: bool = false, time: float = state_switch_time) -> void:
	is_changing_state = true
	curr_posture = Posture.CROUCH if inverse else Posture.STAND
	if inverse: is_running = false
	if ask_run: is_running = true
	var target: float = crouch_height if inverse else stand_height
	state_twn = create_tween()
	state_twn.tween_property(camera_pivot, "position:y", target, time)
	await state_twn.finished
	is_changing_state = false


func prone_to_crouch(inverse: bool = false, time: float = state_switch_time) -> void:
	is_changing_state = true
	curr_posture = Posture.PRONE if inverse else Posture.CROUCH
	var target: float = prone_height if inverse else crouch_height
	state_twn = create_tween()
	state_twn.tween_property(camera_pivot, "position:y", target, time)
	await state_twn.finished
	is_changing_state = false


func prone_to_up(inverse: bool = false, ask_run: bool = false, time: float = state_switch_time) -> void:
	is_changing_state = true
	curr_posture = Posture.CROUCH
	if inverse: is_running = false
	var target: float = prone_height if inverse else stand_height
	state_twn = create_tween()
	state_twn.tween_property(camera_pivot, "position:y", crouch_height, time)
	await state_twn.finished
	await get_tree().create_timer(0.1).timeout
	curr_posture = Posture.PRONE if inverse else Posture.STAND
	if ask_run: is_running = true
	state_twn = create_tween()
	state_twn.tween_property(camera_pivot, "position:y", target, state_switch_time)
	await state_twn.finished
	is_changing_state = false


func crouch_pressed_from_gpad() -> void:
	if not is_grounded or is_changing_state or curr_posture == Posture.CROUCH:
		return
	if curr_posture == Posture.PRONE:
		prone_to_crouch()
		was_it_just_prone_gpad = true
		await get_tree().create_timer(p_inputs.gpad_hold_time_to_prone + 0.01).timeout
		was_it_just_prone_gpad = false
		return
	crouch_to_stand(true)


func crouch_released_from_gpad() -> void:
	if not is_grounded or is_changing_state: return
	if curr_posture == Posture.CROUCH: crouch_to_stand()


func prone_from_gpad() -> void:
	if not is_grounded or is_changing_state or not curr_posture == Posture.CROUCH:
		return
	if was_it_just_prone_gpad:
		crouch_to_stand()
		return
	prone_to_crouch(true)


func capture_jump() -> void:
	if not can_try_jump_action(): return
	if Input.is_action_just_pressed("jump"):
		match curr_posture:
			Posture.STAND when can_jump(): jump()
			Posture.CROUCH: crouch_to_stand()
			Posture.PRONE: prone_to_up()


func can_try_jump_action() -> bool:
	if not p_inputs.is_mouse_locked(): return false
	if not can_play: return false
	return true


func can_jump() -> bool:
	if not is_jump_possible: return false
	if not is_grounded: return false
	if is_reloading: return false
	if is_changing_state: return false
	return true


func jump() -> void:
	velocity.y = jump_strength


func process_movement(delta: float) -> void:
	apply_plane_movement(delta)
	if not is_on_floor():
		velocity += get_gravity() * gravity_multiplier * delta
	move_and_slide()


func apply_plane_movement(delta: float) -> void:
	if not can_play or not p_inputs.is_mouse_locked(): p_inputs.ingore_inputs()
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
		var lcl_max: float = stand_speed * (run_speed_ratio if is_running else 1.0)
		if velocity.length() < lcl_max: velocity += dir * ref_speed * delta
		return

	if is_movement_smooth:
		var lcl_vel: Vector3 = local_velocity
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
		var plane_vel := Vector3(velocity.x, 0.0, velocity.z)
		if plane_vel.length() > applied_speed:
			plane_vel = plane_vel.normalized() * applied_speed
			velocity.x = plane_vel.x
			velocity.z = plane_vel.z
	else:
		var speed: Vector3 = Vector3(dir.x * applied_speed, 0.0, dir.z * applied_speed)
		velocity = Vector3(speed.x, velocity.y, speed.z) if dir else Vector3(0.0, velocity.y, 0.0)


func get_used_speed() -> float:
	if not is_grounded:
		return air_up_speed
	match curr_posture:
		Posture.CROUCH: return crouch_speed
		Posture.PRONE: return prone_speed
		_: return stand_speed


func process_view(delta: float) -> void:
	if not p_inputs.is_mouse_locked(): return
	if not can_play: return
	var inversion: float = -1 if p_inputs.is_inverted else 1
	var reducer: float = (ads_speed_view_reduc if is_aiming else 1.0) * (prone_speed_view_reduc if curr_posture == Posture.PRONE else 1.0)
	aim_target.y -= p_inputs.get_view_input().x * p_inputs.h_sensi_multiplier * reducer
	aim_target.x += p_inputs.get_view_input().y * p_inputs.v_sensi_multiplier * inversion * reducer
	var clamp_applied: Vector2 = v_clamp_prone if curr_posture == Posture.PRONE else v_clamp_deg
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


func handle_camera_effects(delta: float) -> void:
	handle_shoot_recoil()
	handle_fov_changes(delta)


func handle_shoot_recoil() -> void:
	wpn_cam_base.rotation_degrees.x = -recoil_offset


func handle_fov_changes(delta: float) -> void:
	var fov_diff: float = run_fov - default_fov
	if is_running and is_run_fov_active: player_camera.fov = move_toward(player_camera.fov, run_fov, fov_diff * delta * 5.0)
	elif not is_aiming: player_camera.fov = move_toward(player_camera.fov, default_fov, fov_diff * delta * 5.0)
	weapon_camera.fov = player_camera.fov - weapon_fov_diff


func handle_weapon_movement(delta: float) -> void:
	if not has_weapon: return
	handle_weapon_pull_back()
	handle_weapon_bob(delta)
	handle_weapon_sway(delta)
	handle_weapon_lag(delta)


func handle_weapon_pull_back() -> void:
	var was_PB: bool = is_pulling_back
	is_pulling_back = pull_back_cast.is_colliding()
	if is_running: is_pulling_back = true
	if curr_posture == Posture.PRONE and local_velocity: is_pulling_back = true
	if was_PB != is_pulling_back:
		switch_pull_back_state()


func switch_pull_back_state() -> void:
	if is_reloading and is_pulling_back: exit_reload(false)
	var target_marker: Marker3D = pull_back_marker_right if is_right_handed else pull_back_marker_left
	var target_pos: Vector3 = target_marker.position if is_pulling_back else Vector3.ZERO
	var target_rot: Vector3 = target_marker.rotation if is_pulling_back else Vector3.ZERO
	if pull_back_pos_twn:
		pull_back_pos_twn.kill()
		pull_back_rot_twn.kill()
	pull_back_pos_twn = create_tween()
	pull_back_rot_twn = create_tween()
	pull_back_pos_twn.tween_property(sub_wpn_container, "position", target_pos, pull_back_timer)
	pull_back_rot_twn.tween_property(sub_wpn_container, "rotation", target_rot, pull_back_timer)


func handle_weapon_bob(delta: float) -> void:
	var horizontal_speed: float = Vector2(local_velocity.x, local_velocity.z).length()
	var max_speed: float = stand_speed * (run_speed_ratio if is_running else 1.0)
	var tweak: float = (horizontal_speed / max_speed) if ((horizontal_speed / max_speed) == 0.0 or is_aiming) else (horizontal_speed / max_speed) + 0.3
	var target_amount: float = clampf(tweak, 0.0, 1.0)

	if not is_grounded: target_amount = 0.0
	
	if curr_posture == Posture.PRONE:
		target_amount *= prone_bob_freq_factor
	elif curr_posture == Posture.CROUCH:
		target_amount *= crouch_bob_freq_factor

	if is_aiming: target_amount *= ads_bob_freq_factor
	if is_pulling_back: target_amount *= pull_bob_freq_factor

	var freq: float = run_bob_freq if is_running else walk_bob_freq
	
	var targ_bob_pos: Vector3 = walk_bob_pos if curr_posture == Posture.STAND else (crouch_bob_pos if curr_posture == Posture.CROUCH else prone_bob_pos)
	var pos_amp: Vector3 = run_bob_pos if is_running else targ_bob_pos
	
	var targ_bob_rot: Vector3 = walk_bob_rot_deg if curr_posture == Posture.STAND else (crouch_bob_rot_deg if curr_posture == Posture.CROUCH else prone_bob_rot_deg)
	var rot_amp: Vector3 = run_bob_rot_deg if is_running else targ_bob_rot
	
	if is_aiming:
		rot_amp *= ads_bob_amp_factor
		pos_amp *= ads_bob_amp_factor
	
	var targ_smooth: float = bob_default_smooth_speed if not is_running else bob_run_smooth_speed
	bob_amount = lerp(bob_amount, target_amount, dt_lerp(targ_smooth, delta))
	bob_timer += delta * freq * max(bob_amount, 0.05)

	var s: float = sin(bob_timer)
	var c: float = cos(bob_timer)
	var step: float = abs(s)
	var target_pos: Vector3 = weapon_bob_base_pos + Vector3(c * pos_amp.x, step * pos_amp.y, s * pos_amp.z) * bob_amount
	var target_rot: Vector3 = Vector3(s * deg_to_rad(rot_amp.x), c * deg_to_rad(rot_amp.y), c * deg_to_rad(rot_amp.z)) * bob_amount
	weapon_bob_root.position = weapon_bob_root.position.lerp(target_pos,dt_lerp(targ_smooth, delta))
	weapon_bob_root.rotation = lerp_rot(weapon_bob_root.rotation, target_rot, dt_lerp(targ_smooth, delta))
	bob_phase = fposmod(bob_timer, TAU) / TAU


func handle_weapon_sway(delta: float) -> void:
	set_ads_sway_len_by_state()
	set_ads_sway_freq(delta)
	apply_ads_sway()


func set_ads_sway_len_by_state() -> void:
	var reducer: float = prone_sway_reduc if curr_posture == Posture.PRONE else (crouch_sway_reduc if curr_posture == Posture.CROUCH else 1.0)
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
		player_camera.fov = lerp(player_camera.fov, fov_target, dt_lerp(10.0, delta))


func dt_lerp(speed: float, delta: float) -> float:
	return Tools.dt_lerp(speed, delta)


func apply_ads_sway() -> void:
	var pitch: float = cos(sway_timer * sway_x_freq) * curr_sway_len.x
	pitch += aim_noise_y.get_noise_1d(sway_timer * sway_noise_freq) * curr_sway_noise_len
	var yaw: float = sin(sway_timer * sway_y_freq) * curr_sway_len.y
	yaw += aim_noise_x.get_noise_1d(sway_timer * sway_noise_freq) * curr_sway_noise_len
	weapon_sway_root.rotation_degrees.x = pitch
	weapon_sway_root.rotation_degrees.y = yaw


func handle_weapon_lag(delta: float) -> void:
	set_weapon_lag_parameters(delta)
	apply_weapon_pos_lag(delta)
	if is_aiming: apply_weapon_pitch_yaw_lag(delta)
	apply_weapon_roll_lag(delta)


func set_weapon_lag_parameters(delta: float) -> void:
	var root_pos_dist: float = (weapon_container.global_position - weapon_lag_root.global_position).length()
	var targ_pos_dist: float = (weapon_container.global_position - lag_target.global_position).length()
	var targ_pos_speed: float = wpn_pos_lag_close_speed if (root_pos_dist > targ_pos_dist) else wpn_pos_lag_away_speed
	applied_pos_lag_speed = targ_pos_speed * (1.5 if is_aiming else 1.0)

	var root_rot_dist: float = abs(angle_difference(weapon_container.global_rotation.y, weapon_lag_root.global_rotation.y))
	var targ_rot_dist: float = abs(angle_difference(weapon_container.global_rotation.y, lag_target.global_rotation.y))
	var targ_rot_speed: float = wpn_rot_lag_close_speed if (root_rot_dist > targ_rot_dist) else wpn_rot_lag_away_speed
	applied_rot_lag_speed = lerp(applied_rot_lag_speed, targ_rot_speed, dt_lerp(10.0, delta))


func apply_weapon_pos_lag(delta: float) -> void:
	var f_targ: Vector3 = weapon_container.global_position
	var dist: Vector3 = lag_target.global_position - f_targ
	var dist_xz: Vector3 = Vector3(dist.x, 0.0, dist.z)
	var dist_y: Vector3 = Vector3(0.0, dist.y, 0.0)
	var max_xz = max_wpn_xz_pos_lag * concentration_sample * (ads_wpn_pos_lag_reducer if is_aiming else 1.0)
	var max_y = max_wpn_y_pos_lag * concentration_sample

	if dist_xz.length() >= max_xz:
		var dir_xz: Vector3 = dist_xz.normalized()
		var new_xz: Vector3 = f_targ + (dir_xz * max_xz)
		lag_target.global_position = Vector3(new_xz.x, lag_target.global_position.y, new_xz.z)

	if dist_y.length() >= max_y:
		var dir_y: Vector3 = dist_y.normalized()
		var new_y: Vector3 = f_targ + (dir_y * max_y)
		lag_target.global_position.y = new_y.y

	lag_target.global_position = lag_target.global_position.lerp(f_targ, dt_lerp(wpn_pos_lag_close_speed, delta))
	var s_targ: Vector3 = weapon_container.to_local(lag_target.global_position)
	var targ = weapon_lag_root_base_pos + s_targ
	weapon_lag_root.position = weapon_lag_root.position.lerp(targ, dt_lerp(applied_pos_lag_speed, delta))


func apply_weapon_pitch_yaw_lag(delta: float) -> void:
	var f_targ: Vector3 = weapon_container.global_rotation
	var y_diff: float = angle_difference(f_targ.y, lag_target.global_rotation.y)
	var x_diff: float = angle_difference(f_targ.x, lag_target.global_rotation.x)
	var max_y: float = max_wpn_yaw_lag_deg * concentration_sample
	var max_x: float = max_wpn_pitch_lag_deg * concentration_sample

	var y_ratio: float = clampf(abs(y_diff) / deg_to_rad(max_y), 0.0, 1.0)
	var x_ratio := clampf(abs(x_diff) / deg_to_rad(max_x), 0.0, 1.0)
	y_ratio = pow(y_ratio, 1.2)
	x_ratio = pow(x_ratio, 1.2)
	var y_lag: float = deg_to_rad(max_y) * y_ratio * sign(y_diff)
	var x_lag: float = deg_to_rad(max_x) * x_ratio * sign(x_diff)
	lag_target.global_rotation.y = f_targ.y + y_lag
	lag_target.global_rotation.x = f_targ.x + x_lag

	lag_target.global_rotation = lerp_rot(lag_target.global_rotation,f_targ, dt_lerp(wpn_rot_lag_close_speed, delta))
	var parent_q: Quaternion = weapon_container.global_basis.get_rotation_quaternion()
	var target_q: Quaternion = lag_target.global_basis.get_rotation_quaternion()
	var local_q: Quaternion = parent_q.inverse() * target_q
	var s_targ: Vector3 = local_q.get_euler()
	weapon_lag_root.rotation = lerp_rot(weapon_lag_root.rotation, s_targ, dt_lerp(applied_rot_lag_speed, delta))


func apply_weapon_roll_lag(delta: float) -> void:
	var ratio_move: float = -local_velocity.x / (stand_speed * side_speed_ratio)
	var max_yaw_speed: float = deg_to_rad(180.0)
	var ratio_view: float = clampf(view_yaw_speed / max_yaw_speed, -1.0, 1.0)
	var target_move: float = deg_to_rad(max_wpn_roll_lag_from_move_deg) * ratio_move
	var target_view: float = deg_to_rad(max_wpn_roll_lag_from_view_deg) * ratio_view
	var target_z: float = target_view + (target_move / (2.0 if is_running else 1.0))
	var targ: float = lerp_angle(weapon_lag_root.rotation.z, target_z, dt_lerp(wpn_pos_lag_away_speed, delta))
	weapon_lag_root.rotation.z =  targ


func lerp_rot(a: Vector3, b: Vector3, t: float) -> Vector3:
	return Vector3( lerp_angle(a.x, b.x, t), lerp_angle(a.y, b.y, t), lerp_angle(a.z, b.z, t))


func handle_shoot() -> void:
	if not can_use_shoot() : return
	if Input.is_action_just_pressed("shoot"):
		is_weapon_loaded = false
		play_shoot_effects()
		handle_shoot_cast()


func can_use_shoot() -> bool:
	if not p_inputs.is_mouse_locked() : return false
	if not can_play: return false
	if not has_weapon: return false
	if not is_weapon_loaded: return false
	if not can_shoot: return false
	if is_running: return false
	if is_pulling_back: return false
	return true


func play_shoot_effects() -> void:
	if is_aiming: ads_timer += 10.0
	play_shoot_vfx()
	play_recoil_effect()


func play_shoot_vfx() -> void:
	if not EffectsManager.instance:
		printerr("EFFECT MANAGER NOT IN SCENE !")
		return
	var eff: EffectsManager.EffectType = EffectsManager.EffectType.PlayerShoot
	var pos: Vector3 = weapon_ray_cast.global_position
	var rot: Vector3 = weapon_ray_cast.global_rotation
	EffectsManager.instance.play_effect(eff, pos, rot)


func play_recoil_effect() -> void:
	recoil_twn = create_tween()
	recoil_twn.tween_property(self, "recoil_offset", recoil_strength, recoil_time
					).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EaseType.EASE_OUT)
	recoil_twn.tween_property(self, "recoil_offset", 0.0, time_to_return_from_recoil
					).set_trans(Tween.TRANS_SINE).set_ease(Tween.EaseType.EASE_OUT)


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
	if not p_inputs.is_mouse_locked(): return false
	if not can_play: return false
	if not has_weapon: return false
	if is_reloading: return false
	if is_weapon_loaded: return false
	return true


func enter_reload() -> void:
	is_reloading = true
	if is_running:
		is_running = false
		if not is_run_toggle: wait_run_release = true
	reload_ui.reloaded.connect(on_reloaded, CONNECT_ONE_SHOT)
	var default_pos: Vector3 = right_weapon_pos.position if is_right_handed else left_weapon_pos.position
	var time: float = time_to_ads * inverse_lerp(default_pos.x, aim_pos.position.x, weapon_container.position.x)
	await get_tree().create_timer(time).timeout
	if is_reload_interruped or not can_play:
		is_reload_interruped = false
		return
	reload_twn = create_tween()
	await reload_twn.tween_property(weapon_container, "rotation_degrees:x", 25.0, 0.5
					).set_trans(Tween.TRANS_QUART).set_ease(Tween.EaseType.EASE_OUT).finished
	reload_ui.activation(true)


func on_reloaded() -> void:
	exit_reload()


func exit_reload(is_realoded: bool = true, is_from_die = false) -> void:
	reload_ui.activation(false)
	if reload_ui.reloaded.is_connected(on_reloaded):
		reload_ui.reloaded.disconnect(on_reloaded)
	is_reload_interruped = not is_realoded
	if reload_twn: reload_twn.kill()
	if not is_from_die:
		reload_twn = create_tween()
		await reload_twn.tween_property(weapon_container, "rotation_degrees:x", 0.0, 0.5
					).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EaseType.EASE_IN).finished
	is_reloading = false
	if not is_weapon_loaded: is_weapon_loaded = is_realoded
	is_reload_interruped = false


func miss_by_versaillais() -> void:
	missed_by_enemy.emit()


func die() -> void:
	if not is_alive: return
	is_alive = false
	if is_reloading: exit_reload(false, true)
	exit_reload(false, true)
	weapon_sway_root.visible = false
	died.emit()
	reset_player_controller()


func reset_player_controller() -> void:
	kill_all_tweens()
	reload_ui.activation(false)
	velocity = Vector3.ZERO
	local_velocity = Vector3.ZERO
	aim_vel = Vector3.ZERO
	curr_posture = Posture.STAND
	camera_pivot.position.y = stand_height
	global_rotation = Vector3.ZERO
	camera_pivot.rotation = Vector3.ZERO
	weapon_camera.rotation = Vector3.ZERO
	weapon_container.position = right_weapon_pos.position if is_right_handed else left_weapon_pos.position
	weapon_container.rotation = Vector3.ZERO
	sub_wpn_container. rotation = Vector3.ZERO
	sub_wpn_container.position = Vector3.ZERO
	wpn_cam_base.rotation = Vector3.ZERO
	player_camera.fov = default_fov
	weapon_camera.fov = default_fov - weapon_fov_diff
	recoil_offset = 0.0
	ads_timer = 0.0
	sway_timer = 0.0
	concentration_sample = 0.0
	curr_sway_len = Vector2.ZERO
	weapon_sway_root.rotation = Vector3.ZERO
	curr_sway_noise_len = 0.0
	has_weapon = false
	is_aiming = false
	is_running = false
	is_reloading = false
	is_changing_state = false
	synchronise_after_pop()


func synchronise_after_pop() -> void:
	aim_target = Vector3(camera_pivot.rotation_degrees.x, rotation_degrees.y, 0.0)
	weapon_lag_root.position = weapon_lag_root_base_pos
	weapon_lag_root.rotation = Vector3.ZERO
	lag_target.global_position = weapon_container.global_position
	lag_target.global_rotation = weapon_container.global_rotation
	applied_pos_lag_speed = wpn_pos_lag_close_speed
	applied_rot_lag_speed = wpn_rot_lag_close_speed


func kill_all_tweens() -> void:
	if state_twn: state_twn.kill()
	if recoil_twn: recoil_twn.kill()
	if fov_aim_twn: fov_aim_twn.kill()
	if wpn_x_aim_twn: wpn_x_aim_twn.kill()
	if wpn_y_aim_twn: wpn_y_aim_twn.kill()
	if wpn_z_aim_twn: wpn_z_aim_twn.kill()
	if reload_twn: reload_twn.kill()
	if pull_back_pos_twn: pull_back_pos_twn.kill()
	if pull_back_rot_twn: pull_back_rot_twn.kill()


func revive(pos: Vector3, rot: Vector3) -> void:
	initiate(pos, rot)
	player_camera.current = true
