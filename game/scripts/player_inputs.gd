class_name PlayerInputs extends Node

@export_category("Settings")
@export_range(1.0, 20.0, 0.1) var mouse_sensi_default: float = 7.0
@export_range(1.0, 20.0, 0.1) var mouse_sensi_aiming: float = 7.0
@export_range(1.0, 20.0, 0.1) var gpad_sensi_default: float = 7.0
@export_range(1.0, 20.0, 0.1) var gpad_sensi_aiming: float = 7.0
@export var gpad_aiming_curve: Curve
@export var is_inverted: bool = false
@export var is_acceleration_on: bool = true

var aim_vec_gamepad: Vector2 = Vector2.ZERO
var aim_vec_mouse: Vector2 = Vector2.ZERO
var gpad_aim_elapsed: float = 0.0
var is_aiming: bool = false
var is_gamepad: bool = false


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _input(event: InputEvent) -> void:
	if event is InputEventMouse or event is InputEventKey:
		is_gamepad = false
	if event is InputEventJoypadButton or (event is InputEventJoypadMotion and abs(event.axis_value) > 0.1):
		is_gamepad = true
	if event is InputEventMouseMotion:
		aim_vec_mouse = event.relative * (mouse_sensi_aiming if is_aiming else mouse_sensi_default) / 100.0
	if event is InputEventKey and event.is_pressed() and event.keycode == KEY_ESCAPE:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE else Input.MOUSE_MODE_VISIBLE


func _process(delta: float) -> void:
	capture_inputs(delta)
	aim_vec_mouse = Vector2.ZERO


func capture_inputs(delta) -> void:
	var aim_vec: Vector2 = Input.get_vector("aim_left","aim_right","aim_top","aim_down", 0.1)
	if aim_vec.length() >= 0.95: gpad_aim_elapsed += delta * 4.0
	if aim_vec.length() <= 0.1: gpad_aim_elapsed = 0.0
	if gpad_aim_elapsed >= 1.0: gpad_aim_elapsed = 1.0
	var ratio: float = 10 - (9.0 * gpad_aiming_curve.sample(gpad_aim_elapsed))
	aim_vec_gamepad = Input.get_vector("aim_left","aim_right","aim_top","aim_down", 0.1) * (gpad_sensi_aiming if is_aiming else gpad_sensi_default) / ratio


func get_view_input() -> Vector2:
	return aim_vec_gamepad if is_gamepad else aim_vec_mouse
