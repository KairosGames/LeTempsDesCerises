class_name UIManager extends Control

@onready var tooltip: Tooltip = %Tooltip
@onready var pause_container: PanelContainer = %PauseContainer
@onready var tutorial_km: PanelContainer = %TutorialKeyboardMouse
@onready var tutorial_gpad: PanelContainer = %TutorialGamepad
@onready var options: ButtonBehavior = %Options
@onready var quit: ButtonBehavior = %Quit
@onready var objective_container: VBoxContainer = %ObjectiveContainer
@onready var objective_label: Label = %ObjectiveLabel
@onready var objective_target: ObjectiveTarget = %ObjectiveTarget
@onready var top_strip: ColorRect = %TopStrip
@onready var bottom_strip: ColorRect = %BottomStrip
@onready var dark_fade: DarkFade = %DarkFade
@onready var choice_tooltip: ChoiceTooltip = %ChoiceTooltip

@export_category("Letter box")
@export var time_to_open_letter_box: float = 0.35

var game_manager: GameManager
var player: Player
var on_process: Array[Callable]
var tuto_twn: Tween
var is_tutorial: bool = false

var is_tutorial_skipable: bool = false
var is_letter_box_open: bool = false

var strip_twn: Tween


static var instance: UIManager:
	set(value):
		if not instance: instance = value
		else: push_error("MORE THAN ONE UI_MANAGER IN SCENE")


func _ready() -> void:
	instance = self
	tooltip.visible = false
	pause_container.visible = false
	tutorial_km.visible = false
	tutorial_gpad.visible = false
	set_objective(false)
	ready_deferred.call_deferred()


func ready_deferred() -> void:
	game_manager = GameManager.instance
	if Player.instance: player = Player.instance
	else: game_manager.player_instance_loaded.connect(set_local_player, CONNECT_ONE_SHOT)


func set_local_player() -> void:
	player = Player.instance
	objective_target.controller_node = player
	objective_target.camera_node = player.player_camera
	objective_target.target = null


func _process(_delta: float) -> void:
	for callable: Callable in on_process: callable.call()


func _input(event: InputEvent) -> void:
	if (event is InputEventMouseButton or event is InputEventKey or event is InputEventJoypadButton) and is_tutorial:
		if is_tutorial_skipable: exit_tutorial()


func clear_process() -> void:
	on_process.clear()


func enter_tutorial() -> void:
	player.can_play = false
	if tuto_twn: tuto_twn.kill()
	tuto_twn = create_tween()
	tuto_twn.set_ignore_time_scale(true)
	tuto_twn.tween_property(Engine, "time_scale", 0.0, 0.37)
	on_process.push_back(process_tutorial)
	is_tutorial = true
	wait_to_skip_tutorial()


func wait_to_skip_tutorial() -> void:
	await get_tree().create_timer(2.0, true, false, true).timeout
	is_tutorial_skipable = true


func exit_tutorial() -> void:
	clear_process()
	tutorial_km.visible = false
	tutorial_gpad.visible = false
	if tuto_twn: tuto_twn.kill()
	tuto_twn = create_tween()
	tuto_twn.set_ignore_time_scale(true)
	tuto_twn.tween_property(Engine, "time_scale", 1.0, 0.37)
	player.can_play = true
	set_exit_tutorial.call_deferred()


func set_exit_tutorial() -> void:
	await get_tree().create_timer(0.1).timeout
	is_tutorial = false
	is_tutorial_skipable = false


func process_tutorial() -> void:
	tutorial_gpad.visible = player.p_inputs.is_gamepad
	tutorial_km.visible = not player.p_inputs.is_gamepad


func process_mouse_mode()-> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED if player.p_inputs.is_gamepad else Input.MOUSE_MODE_VISIBLE
	if player.p_inputs.is_gamepad:
		if not (options.has_focus() or quit.has_focus()): options.grab_focus()
		if options.is_hovered(): options.mouse_filter = Control.MOUSE_FILTER_IGNORE
		if quit.is_hovered(): quit.mouse_filter = Control.MOUSE_FILTER_IGNORE
	else:
		if options.mouse_filter != Control.MOUSE_FILTER_STOP: options.mouse_filter = Control.MOUSE_FILTER_STOP
		if quit.mouse_filter != Control.MOUSE_FILTER_STOP: quit.mouse_filter = Control.MOUSE_FILTER_STOP
		get_viewport().gui_release_focus()


func set_pause(is_pause: bool) -> void:
	pause_container.visible = is_pause
	if is_pause: on_process.push_back(process_mouse_mode)
	else: clear_process()
	if player.p_inputs.is_gamepad: options.grab_focus()
	else: Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if is_pause else Input.MOUSE_MODE_CAPTURED


func set_objective(is_active: bool, target: Node3D = null, objective: String = "") -> void:
	objective_label.text = "· " + objective
	objective_container.visible = is_active
	objective_target.target = target


func hard_set_letter_box(to_open: bool) -> void:
	top_strip.size_flags_stretch_ratio = 1.0 if to_open else 0.0
	bottom_strip.size_flags_stretch_ratio = 1.0 if to_open else 0.0


func launch_letter_box(to_open: bool) -> void:
	if strip_twn: strip_twn.kill()
	strip_twn = create_tween()
	var target: float = 1.0 if to_open else 0.0
	var ratio: float = 1.0 - top_strip.size_flags_stretch_ratio if to_open else top_strip.size_flags_stretch_ratio
	var time: float =  time_to_open_letter_box * ratio
	strip_twn.tween_property(top_strip, "size_flags_stretch_ratio", target, time)
	await strip_twn.set_parallel().tween_property(bottom_strip, "size_flags_stretch_ratio", target, time).finished
