class_name ReloadUI extends Control

signal reloaded
signal try_failed
signal try_succeeded

@onready var focus: ColorRect = %ReloadFocus
@onready var pos1: Control = %ReloadPos1
@onready var pos2: Control = %ReloadPos2
@onready var pos3: Control = %ReloadPos3

@export_category("Configuration settings")
@export var all_pos: Array[Control]
@export var pos_to_rect: Array[ColorRect]
@export var steps: Array[Array]

@export_category("QTE settings")
@export var speed_px_sec: float = 100.0
@export var max_step_count: float = 5
@export var qte_delay: float = 0.5
@export var valid_offset_px: float = 10.0

@export_category("Color settings")
@export var default_color: Color
@export var valid_target_color: Color
@export var default_focus_color: Color
@export var fail_focus_color: Color
@export var sucess_focus_color: Color

var curr_target: Control
var valid_target: Control
var curr_targets: Array
var step: int = 0
var counter: int = 0
var target_i: int = 1
var is_active: bool = false
var can_qte: bool = true


func _ready() -> void:
	set_step()


func _process(delta: float) -> void:
	if is_active:
		handle_reload_phase(delta)
		capture_reload_QTE()


func activation(active: bool):
	step = 0
	set_step()
	visible = active
	is_active = active


func handle_reload_phase(delta: float) -> void:
	var dist_vec: Vector2 = curr_target.global_position - focus.global_position
	var move_vec: Vector2 = dist_vec.normalized()
	focus.global_position += move_vec * delta * speed_px_sec
	if dist_vec.length() <= 1.0:
		switch_target()


func set_step() -> void:
	counter = 0
	target_i = 1
	curr_targets = steps[step]
	focus.global_position = all_pos[curr_targets[0]].global_position
	curr_target = all_pos[curr_targets[1]]
	valid_target = all_pos[curr_targets[1]]
	for i in range(pos_to_rect.size()):
		pos_to_rect[i].color = default_color
		if i == curr_targets[1]: pos_to_rect[i].color = valid_target_color


func switch_target() -> void:
	counter += 1
	if counter >= max_step_count:
		go_next_step()
		try_succeeded.emit()
		return
	target_i += 1
	if target_i >= curr_targets.size():
		target_i = 0
	curr_target = all_pos[curr_targets[target_i]]


func go_next_step() -> void:
	step +=1
	if step >= steps.size():
		reloaded.emit()
		return
	set_step()


func capture_reload_QTE() -> void:
	if not can_reload_QTE(): return
	if Input.is_action_just_pressed("reload"):
		try_qte()


func can_reload_QTE() -> bool:
	return Input.mouse_mode == Input.MouseMode.MOUSE_MODE_CAPTURED and can_qte


func try_qte() -> void:
	can_qte = false
	var dist: float = (valid_target.global_position - focus.global_position).length()
	if dist <= valid_offset_px:
		go_next_step()
		try_succeeded.emit()
		focus.color = sucess_focus_color
	else:
		focus.color = fail_focus_color
		try_failed.emit()
	await get_tree().create_timer(qte_delay).timeout
	can_qte = true
	focus.color = default_focus_color
