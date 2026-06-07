class_name ReloadUI extends Control

signal entered_reload
signal try_failed
signal try_succeeded
signal reloaded

@onready var focus: ColorRect = %ReloadFocus
@onready var pos1: Control = %ReloadPos1
@onready var pos2: Control = %ReloadPos2
@onready var pos3: Control = %ReloadPos3
@onready var chassepot: Chassepot = %sk_chassepot

@export_category("References")
@export var wpn_animator: AnimationPlayer

@export_category("Configuration settings")
@export var all_pos: Array[Control]
@export var pos_to_rect: Array[ColorRect]
@export var steps: Array[Array]

@export_category("QTE settings")
@export var speed_px_sec: float = 100.0
@export var max_step_count: float = 5
@export var qte_delay: float = 0.5
@export var valid_offset_px: float = 15.0

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
var is_hammer_cocked = false
var is_tutorial: bool = false
var is_playing_qte: bool = true


func _ready() -> void:
	wpn_animator.play("idle")
	chassepot.call_load_ammo = play_amo_anim
	chassepot.call_next_step = go_next_step_after_ammo_anim
	set_step(0)


func _process(delta: float) -> void:
	if is_active and step != 2:
		if is_playing_qte: handle_reload_phase(delta)
		capture_reload_QTE()


func activation(active: bool):
	if active: entered_reload.emit()
	set_step(step)
	visible = active
	is_active = active


func handle_reload_phase(delta: float) -> void:
	var dist_vec: Vector2 = curr_target.global_position - focus.global_position
	var move_vec: Vector2 = dist_vec.normalized()
	focus.global_position += move_vec * delta * speed_px_sec
	if dist_vec.length() <= 1.0:
		switch_target()


func set_step(p_step: int) -> void:
	if step == 2: return
	step = p_step
	if step >= steps.size() : step = 0
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
	if not is_tutorial: counter += 1
	if counter >= max_step_count:
		var anim_name: String = "go_step_" + str(step + 1)
		wpn_animator.play(anim_name)
		if step == 1:
			focus.visible = false
			pos_to_rect[2].color = default_color
		go_next_step()
		try_succeeded.emit()
		return
	target_i += 1
	if target_i >= curr_targets.size():
		target_i = 0
	curr_target = all_pos[curr_targets[target_i]]


func go_next_step() -> void:
	step += 1
	if step >= steps.size():
		reloaded.emit()
		return
	if step != 2:
		set_step(step)
		return


func capture_reload_QTE() -> void:
	if not can_reload_QTE(): return
	if Input.is_action_just_pressed("reload"):
		try_qte()


func can_reload_QTE() -> bool:
	return Input.mouse_mode == Input.MouseMode.MOUSE_MODE_CAPTURED and can_qte and not is_tutorial


func try_qte() -> void:
	can_qte = false
	var dist: float = (valid_target.global_position - focus.global_position).length()
	if dist <= valid_offset_px:
		var anim_name: String = "go_step_" + str(step + 1)
		wpn_animator.play(anim_name)
		if step == 1:
			focus.visible = false
			pos_to_rect[2].color = default_color
		go_next_step()
		try_succeeded.emit()
		focus.color = sucess_focus_color
	else:
		focus.color = fail_focus_color
		try_failed.emit()
	await get_tree().create_timer(qte_delay).timeout
	can_qte = true
	focus.color = default_focus_color


func play_amo_anim() -> void:
	wpn_animator.play("go_step_3")


func go_next_step_after_ammo_anim() -> void:
	focus.visible = true
	go_next_step()


func cock_hammer(time_to_wait: float) -> void:
	await get_tree().create_timer(time_to_wait).timeout
	is_hammer_cocked = true
	wpn_animator.play("go_step_0")
