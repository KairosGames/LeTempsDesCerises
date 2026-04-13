class_name Player extends CharacterBody3D

@onready var player_inputs: PlayerInputs = %PlayerInputs
@onready var camera_pivot: Node3D = %CameraPivot
@onready var player_camera: Camera3D = %PlayerCamera
@onready var weapon_container: Node3D = %WeaponContainer
@onready var default_weapon_pos: Marker3D = %DefaultWeaponPos
@onready var aim_pos: Marker3D = %AimPos
@onready var weapon_ray_cast: RayCast3D = %WeaponRayCast

@export_category("Exposed settings")
@export var is_aim_locked: bool = true
@export var is_run_lock: bool = true
@export var is_position_switcher_locked: bool = true
@export var is_aim_smooth: bool = true
@export var is_movement_smooth: bool = true

@export_category("View settings")
@export var v_clamp_deg: Vector2 = Vector2(-70.0, 70.0)
@export_range(0.01, 1.0, 0.01) var aiming_reducer_ratio: float = 0.5
@export var default_fov: float = 75.0
@export var aiming_fov: float = 50.0

@export_category("States settings")
@export var can_run_crouched: bool = true
@export var can_run_lyied_d: bool = true
@export var standing_height: float = 1.6
@export var crouch_height: float = 1.1
@export var lyingd_height: float = 0.35

@export_category("Movement speed settings")
@export var standing_speed: float = 5.0
@export var crouch_speed: float = 3.0
@export var lying_d_speed: float = 1.0
@export var air_up_speed: float = 0.1
@export_range(1.0, 3.0, 0.01) var run_speed_ratio: float = 1.5
@export_range(0.0, 1.0, 0.01) var side_speed_ratio: float = 0.75
@export_range(0.0, 1.0, 0.01) var back_speed_ratio: float = 0.6

@export_category("Smoothness settings")
@export_range(0.01, 0.5, 0.01) var acc_time: float = 0.1
@export_range(0.01, 0.5, 0.01) var brake_time: float = 0.1
@export_range(0.01, 1.0, 0.001) var aim_smooth_strength: float = 0.05

var is_grounded: bool = true
var is_aiming: bool = false
var is_running: bool = false
var is_crouched:bool = false
var is_lyied_d: bool = false

var aim_vel: Vector3 = Vector3.ZERO
var aim_target: Vector3 = Vector3.ZERO
var acc_time_ratio: float
var brake_time_ratio: float

const JUMP_VELOCITY = 4.5

func _ready() -> void:
	aim_target = Vector3(camera_pivot.rotation_degrees.x, rotation_degrees.y, 0.0)
	acc_time_ratio = (1 / acc_time)
	brake_time_ratio = (1 / brake_time)


func _process(delta: float) -> void:
	process_movement(delta)
	capture_states()
	handle_states(delta)
	process_view(delta)
	handle_shoot(delta)


func process_movement(delta: float) -> void:
	apply_plane_movement(delta)
	
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	move_and_slide()


func apply_plane_movement(delta: float) -> void:
	var mov_vec: Vector2 = player_inputs.move_vec
	var ref_speed = get_applied_speed()
	
	var f_speed: float = ref_speed * abs(mov_vec.y)
	if mov_vec.y < 0 : f_speed *= back_speed_ratio
	var s_speed: float = abs(mov_vec.x) * ref_speed * side_speed_ratio
	var applied_speed: float = sqrt(f_speed * f_speed + s_speed * s_speed)
	
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
		var dir: Vector3 = (transform.basis * Vector3(mov_vec.x, 0, mov_vec.y).normalized())
		var speed: Vector3 = Vector3(dir.x * applied_speed, 0.0, dir.z * applied_speed)
		velocity = Vector3(speed.x, velocity.y, speed.z) if dir else Vector3(0.0, velocity.y, 0.0)


func get_applied_speed() -> float:
	if is_crouched:
		return crouch_speed
	elif is_lyied_d:
		return lying_d_speed
	elif not is_grounded:
		return air_up_speed
	else:
		return standing_speed


func capture_states() -> void:
	capture_aim_state()
	capture_position_state()


func capture_aim_state() -> void:
	if is_aim_locked:
		if Input.is_action_just_pressed("aim"): is_aiming = !is_aiming
	else:
		is_aiming = Input.is_action_just_pressed("aim")
	player_inputs.is_aiming = is_aiming


func capture_position_state() -> void:
	if Input.is_action_just_pressed("crouch"):
		if not is_grounded: return
		if is_lyied_d: is_lyied_d = false
		if is_running: is_running = false
		is_crouched = !is_crouched
	
	if Input.is_action_just_pressed("lying_down"):
		if not is_grounded: return
		if is_lyied_d: is_crouched = true
		if is_running: is_running = false
		is_lyied_d = !is_lyied_d
		
	if Input.is_action_just_pressed("run"):
		if not is_grounded: return
		if is_crouched: is_crouched = false
		if is_lyied_d: is_lyied_d = false
		is_running = !is_running


func handle_states(delta: float) -> void:
	handle_aim_state(delta)
	handle_position_state(delta)


func handle_aim_state(delta: float) -> void:
	var target_pos: Vector3 = aim_pos.position if is_aiming else default_weapon_pos.position
	var target_fov: float = aiming_fov if is_aiming else default_fov
	weapon_container.position = weapon_container.position.lerp(target_pos, 0.15)
	player_camera.fov = lerp(player_camera.fov, target_fov, 0.05)
	#var a = -10.0 if is_aiming else 0.0
	#player_camera.rotation_degrees.z = lerp_angle(player_camera.rotation_degrees.z, a, 0.1)


func handle_position_state(delta: float) -> void:
	if not is_crouched and not is_lyied_d: camera_pivot.position.y = 1.6
	if is_crouched : camera_pivot.position.y = 1.1
	if is_lyied_d: camera_pivot.position.y = 0.35

func process_view(delta: float) -> void:
	if not is_mouse_locked(): return
	var input: PlayerInputs = player_inputs
	var inversion = -1 if player_inputs.is_inverted else 1
	var reducer = aiming_reducer_ratio if is_aiming else 1.0
	aim_target.y -= input.get_view_input().x * input.h_sensi_multiplier * reducer
	aim_target.x += input.get_view_input().y * input.v_sensi_multiplier * inversion * reducer
	aim_target.x = clampf(aim_target.x, v_clamp_deg.x, v_clamp_deg.y)
	
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


func handle_shoot(delta: float) -> void:
	if not Input.is_action_just_pressed("shoot"):
		return
	var obj: Object = weapon_ray_cast.get_collider()
	if not obj or obj is not ShootTarget:
		print("MISS !")
		return
	var target: ShootTarget = obj as ShootTarget
	if target.is_ally:
		print("Ally touched !")
		return
	print("Enemy touched !")

func is_mouse_locked() -> bool: return Input.mouse_mode == Input.MouseMode.MOUSE_MODE_CAPTURED
