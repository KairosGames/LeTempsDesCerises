class_name PlayerInputs extends Node

@export_category("Exposed Settings")
@export var is_inverted: bool = false
@export_range(1.0, 20.0, 0.1) var sensi_default: float = 7.0
@export_range(1.0, 20.0, 0.1) var sensi_aiming: float = 4.0
@export_range(0.1, 2.0, 0.1) var h_sensi_multiplier: float = 1.0
@export_range(0.1, 2.0, 0.1) var v_sensi_multiplier: float = 1.0
@export_range(0.05, 0.8, 0.01) var l_jstick_threshold: float = 0.2
@export_range(0.05, 0.8, 0.01) var r_jstick_threshold: float = 0.2

@export_category("Gamepad Settings")
@export_range(0.05, 0.8, 0.01) var gpad_detect_threshold: float = 0.2

@export_category("Gamepad Aim Settings")
@export var gpad_aim_max_speed: float = 5.0
@export var gpad_speed_aiming_curve: Curve
@export var is_aim_acc_on: bool = true
@export var gpad_aim_acc_speed: float = 10.0
@export_range(0.8, 1.0, 0.01) var acc_threshold: float = 0.95
@export var gpad_aim_time_before_acc: float = 0.2
@export var gpad_aim_acc_speed_time: float = 0.3

var aim_vec_gamepad: Vector2 = Vector2.ZERO
var aim_vec_mouse: Vector2 = Vector2.ZERO
var gpad_aim_timers: Vector2 = Vector2.ZERO
var move_vec: Vector2 = Vector2.ZERO
var is_aiming: bool = false
var is_gamepad: bool = false


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _input(event: InputEvent) -> void:
	if event is InputEventMouse or event is InputEventKey:
		is_gamepad = false
	if event is InputEventJoypadButton or (event is InputEventJoypadMotion and abs(event.axis_value) > gpad_detect_threshold):
		is_gamepad = true
	if event is InputEventMouseMotion:
		aim_vec_mouse = event.relative * (sensi_aiming if is_aiming else sensi_default) * 0.1
	if event is InputEventKey and event.is_pressed() and event.keycode == KEY_ESCAPE:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE else Input.MOUSE_MODE_VISIBLE


func _process(delta: float) -> void:
	capture_inputs(delta)
	aim_vec_mouse = Vector2.ZERO


func capture_inputs(delta: float) -> void:
	capture_gpad_aim(delta)
	capture_movement()


func capture_gpad_aim(delta: float) -> void:
	var aim_vec: Vector2 = Input.get_vector("aim_left","aim_right","aim_top","aim_down",r_jstick_threshold)
	var speed_to_add: float = 0.0
	if is_aim_acc_on:
		set_gpad_aim_timers(aim_vec, delta)
		if gpad_aim_timers.x >= gpad_aim_time_before_acc:
			var ratio: float = inverse_lerp(0.0, gpad_aim_acc_speed_time, gpad_aim_timers.y)
			speed_to_add = (gpad_aim_acc_speed - gpad_aim_max_speed) * ratio
	var speed: float = (gpad_speed_aiming_curve.sample(aim_vec.length()) * gpad_aim_max_speed) + speed_to_add
	var sensi: float = sensi_aiming if is_aiming else sensi_default
	aim_vec_gamepad = aim_vec * speed * sensi * 0.1


func set_gpad_aim_timers(aim_vec: Vector2, delta: float):
	if aim_vec.length() >= acc_threshold: gpad_aim_timers.x += delta
	else :
		gpad_aim_timers = Vector2.ZERO
		return
	if gpad_aim_timers.x >= gpad_aim_time_before_acc :
		gpad_aim_timers.x = gpad_aim_time_before_acc
		gpad_aim_timers.y += delta
		if gpad_aim_timers.y >= gpad_aim_acc_speed_time : gpad_aim_timers.y = gpad_aim_acc_speed_time


func capture_movement() -> void:
	move_vec = Input.get_vector("move_right", "move_left", "move_back", "move_forward", l_jstick_threshold)


func get_view_input() -> Vector2:
	return aim_vec_gamepad if is_gamepad else aim_vec_mouse


func get_move_inpit() -> Vector2:
	return move_vec
