class_name ReloadUI extends Control

signal entered_reload
signal try_failed
signal try_succeeded
signal reloaded

@onready var focus: PathFollow2D = %Focus
@onready var focus_pin: Sprite2D = %FocusPin
@onready var path1: Path2D = %Path1
@onready var path2: Path2D = %Path2
@onready var chassepot: Chassepot = %Chassepot

@export_category("Reload Settings")
@export var step_display: Array[TextureRect]
@export var start_progress: Array[float]
@export var target_progress: Array[float]

@export_category("References")
@export var wpn_animator: AnimationPlayer

@export_category("QTE settings")
@export var speed: float = 1.0
@export var max_counter: float = 5.0
@export var qte_delay: float = 0.5
@export var valid_off_set_ratio: float = 0.21

@export_category("Color settings")
@export var default_focus_color: Color
@export var fail_focus_color: Color
@export var sucess_focus_color: Color

var step: int = 0
var counter: int = 0
var proogress_dir: float = 1.0
var pin_target_ratio: float = 1.0
var is_active: bool = false
var can_qte: bool = true
var is_hammer_cocked: bool = false
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


func activation(active: bool) -> void:
	if active: entered_reload.emit()
	set_step(step)
	visible = active
	is_active = active


func handle_reload_phase(delta: float) -> void:
	if not focus.visible: focus.visible = true
	focus.progress_ratio += proogress_dir * delta * speed
	if focus.progress_ratio == pin_target_ratio:
		switch_target()


func set_step(p_step: int) -> void:
	if step == 2: return
	step = p_step
	if step >= 5 : step = 0
	counter = 0
	if step <= 1: proogress_dir = 1.0
	else: proogress_dir = -1.0
	if step == 0 or step == 4: focus.reparent(path1)
	else: focus.reparent(path2)
	for i: int in range(5): if step_display[i]: step_display[i].visible = i == step
	focus.progress_ratio = start_progress[step]
	pin_target_ratio = target_progress[step]


func switch_target() -> void:
	if not is_tutorial: counter += 1
	pin_target_ratio = 1.0 if pin_target_ratio == 0.0 else 0.0
	proogress_dir *= -1.0
	if counter >= max_counter:
		var anim_name: String = "go_step_" + str(step + 1)
		wpn_animator.play(anim_name)
		if step == 1:
			focus.visible = false
		go_next_step()
		try_succeeded.emit()
		return


func go_next_step() -> void:
	step += 1
	if step >= 5:
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
	var is_in: bool = abs(focus.progress_ratio - target_progress[step]) <= valid_off_set_ratio
	if is_in:
		var anim_name: String = "go_step_" + str(step + 1)
		wpn_animator.play(anim_name)
		if step == 1:
			focus.visible = false
		go_next_step()
		try_succeeded.emit()
		focus_pin.modulate = sucess_focus_color
	else:
		focus_pin.modulate = fail_focus_color
		try_failed.emit()
	await get_tree().create_timer(qte_delay).timeout
	can_qte = true
	focus_pin.modulate = default_focus_color


func play_amo_anim() -> void:
	wpn_animator.play("go_step_3")


func go_next_step_after_ammo_anim() -> void:
	focus.visible = true
	go_next_step()


func cock_hammer(time_to_wait: float) -> void:
	await get_tree().create_timer(time_to_wait).timeout
	is_hammer_cocked = true
	wpn_animator.play("go_step_0")
