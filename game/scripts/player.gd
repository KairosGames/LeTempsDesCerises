class_name Player extends CharacterBody3D

@onready var player_inputs: PlayerInputs = %PlayerInputs
@onready var camera_pivot: Node3D = %CameraPivot
@onready var player_camera: Camera3D = %PlayerCamera

@export_category("Exposed settings")
@export var is_aim_locked: bool = true
@export var is_position_switcher_locked: bool = true
@export var is_aim_smooth: bool = true
@export var is_movement_smooth: bool = true

@export_category("View settings")
@export var v_clamp_deg: Vector2 = Vector2(-70.0, 70.0)

@export_category("States settings")
@export var can_crouch: bool = true
@export var can_lyingd: bool = true
@export var can_run_crouched: bool = true
@export var can_run_lyied_d: bool = true

@export_category("Movement speed settings")
@export var standing_speed: float = 5.0
@export var crouch_speed: float = 3.0
@export var lying_d_speed: float = 1.0
@export var air_up_speed: float = 0.1
@export_range(1.0, 3.0, 0.01) var run_speed_ratio: float = 1.5
@export_range(0.0, 1.0, 0.01) var side_speed_ratio: float = 0.75
@export_range(0.0, 1.0, 0.01) var back_speed_ratio: float = 0.6

@export_category("Smoothness settings")
@export_range(0.0, 0.5, 0.01) var acc_time: float = 0.1
@export_range(0.0, 0.5, 0.01) var brake_time: float = 0.1

var is_grounded: bool = true
var is_running: bool = false
var is_crouched:bool = false
var is_lyied_d: bool = false

var last_vel: Vector3
var acc_time_ratio: float
var brake_time_ratio: float

const JUMP_VELOCITY = 4.5


func _ready() -> void:
	acc_time_ratio = (1 / acc_time) if acc_time != 0.0 else 0.0
	brake_time_ratio = (1 / brake_time) if brake_time != 0.0 else 0.0


func _process(delta: float) -> void:
	process_view()
	process_movement(delta)


func process_view() -> void:
	var input: PlayerInputs = player_inputs
	var inversion = -1 if player_inputs.is_inverted else 1
	rotation_degrees.y -=  input.get_view_input().x * input.h_sensi_multiplier
	camera_pivot.rotation_degrees.x += input.get_view_input().y * input.v_sensi_multiplier * inversion
	camera_pivot.rotation_degrees.x = clampf(camera_pivot.rotation_degrees.x, v_clamp_deg.x, v_clamp_deg.y)


func process_movement(delta: float) -> void:
	apply_plane_movement(delta)
	
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	move_and_slide()


func apply_plane_movement(delta: float):
	var mov_vec: Vector2 = player_inputs.move_vec
	var ref_speed = get_applied_speed()
	
	var f_speed: float = ref_speed * abs(mov_vec.y)
	if mov_vec.y < 0 : f_speed *= back_speed_ratio
	var s_speed: float = abs(mov_vec.x) * ref_speed * side_speed_ratio
	var applied_speed: float = sqrt(f_speed * f_speed + s_speed * s_speed)
	
	var dir: Vector3 = (transform.basis * Vector3(mov_vec.x, 0, mov_vec.y).normalized())
	var speed: Vector3 = Vector3(dir.x * applied_speed, 0.0, dir.z * applied_speed)
	
	if speed.x != 0.0 : last_vel.x = velocity.x
	if speed.z != 0.0 : last_vel.z = velocity.z
	
	if is_movement_smooth:
		if dir.x:
			velocity.x = move_toward(velocity.x, speed.x, abs(speed.x) * delta * acc_time_ratio)
			if sign(speed.x) != 0 and sign(velocity.x) != sign(speed.x):
				velocity.x = move_toward(velocity.x, speed.x, abs(speed.x) * delta * acc_time_ratio)
		else:
			velocity.x = move_toward(velocity.x, 0.0, abs(last_vel.x) * delta * brake_time_ratio)
		
		if dir.z:
			velocity.z = move_toward(velocity.z, speed.z, abs(speed.z) * delta * acc_time_ratio)
			if sign(speed.z) != 0 and sign(velocity.z) != sign(speed.z):
				velocity.z = move_toward(velocity.z, speed.z, abs(speed.z) * delta * acc_time_ratio)
		else:
			velocity.z = move_toward(velocity.z, 0.0, abs(last_vel.z) * delta * brake_time_ratio)
	else:
		pass


func get_applied_speed() -> float:
	if is_crouched:
		return crouch_speed
	elif is_lyied_d:
		return lying_d_speed
	elif not is_grounded:
		return air_up_speed
	else:
		return standing_speed
