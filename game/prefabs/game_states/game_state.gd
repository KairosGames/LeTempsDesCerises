@abstract class_name GameState extends Node

signal voice_line_called(index: int)
@warning_ignore("unused_signal") signal completed
@warning_ignore("unused_signal") signal voice_line_finished

@abstract func enter() -> void
@abstract func exit() -> void

var steps: Array[Step] = []
var curr_step: int = 0
var is_active = false

var game_manager: GameManager
var eff_manager: EffectsManager
var ui_manager: UIManager
var player: Player
var on_process: Array[Callable]
var on_ui_process: Array[Callable]
var delta_t: float
var voice_line_index: int = -1
var local_bool: bool
var was_gpad: bool

var rot_twn: Tween


func _ready() -> void:
	ready_deffered.call_deferred()


func ready_deffered() -> void:
	game_manager = GameManager.instance
	eff_manager = EffectsManager.instance
	ui_manager = UIManager.instance
	player = Player.instance


func _process(delta: float) -> void:
	if not is_active: return
	delta_t = delta
	for callable: Callable in on_process: callable.call()
	for callable: Callable in on_ui_process: callable.call()
	if Input.is_action_just_pressed("go_next_step") and game_manager.is_game_playing():
		print("NEXT CALLED")
		voice_line_finished.emit()


func run_steps() -> void:
	for step in steps:
		step.curr_state = Step.StepState.ENTER
		await step.on_enter.call()
		step.curr_state = Step.StepState.DOING
		await step.on_doing.call()
		step.curr_state = Step.StepState.EXIT
		await step.on_exit.call()
		print("STEP ", curr_step, " PASSED !")
		curr_step += 1
	completed.emit()


func set_player_for_debug() -> void:
	player.blink_effect.set_eyes_to_step(BlinkEffect.EyesStep.OPEN)
	player.give_or_drop_weapon(true)
	player.is_weapon_loaded = true


func do_nothing(_p: float = 0.0) -> void:
	pass


func add_on_process(callable: Callable, is_ui: bool = false) -> void:
	if is_ui:
		on_ui_process.push_back(callable)
		return
	on_process.push_back(callable)


func clean_process() -> void:
	on_process.clear()


func clean_ui_process() -> void:
	on_ui_process.clear()


func wait(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout


func wait_until(condition: Callable) -> void:
	while not condition.call() or not game_manager.is_game_playing():
		await get_tree().process_frame


func wait_signal(signal_to_wait: Signal) -> void:
	await signal_to_wait


func wait_until_or_signal(condition: Callable, signal_to_wait: Signal) -> void:
	local_bool = false
	signal_to_wait.connect(set_local_bool)
	while not local_bool:
		local_bool = condition.call() and game_manager.is_game_playing()
		await get_tree().process_frame
	signal_to_wait.disconnect(set_local_bool)


func set_local_bool() -> void:
	local_bool = game_manager.is_game_playing()


func wait_voice() -> void:
	voice_line_index += 1
	voice_line_called.emit(voice_line_index)
	print("WAIT VOICE LINE")
	await voice_line_finished


func take_player_move_control(is_taken: bool) -> void:
	player.p_inputs.is_game_controlling_movement = is_taken
	player.p_inputs.move_vec = Vector2.ZERO


func take_player_view_control(is_taken: bool) -> void:
	player.p_inputs.is_game_controlling_view = is_taken
	player.p_inputs.aim_vec_gamepad = Vector2.ZERO
	player.p_inputs.aim_vec_mouse = Vector2.ZERO


func set_player_move(dir: Vector2) -> void:
	player.p_inputs.move_vec = dir.normalized()


func rotate_yaw_player_to_pos(pos: Vector3, speed: float, delta: float) -> void:
	var dir = player.global_position - pos
	var target_angle = atan2(-dir.x, -dir.z)
	var arg1 = deg_to_rad(player.aim_target.y)
	player.aim_target.y = rad_to_deg(rotate_toward(arg1, target_angle, speed * delta))


func rotate_player_to_yaw(yaw: float, speed: float, delta: float) -> void:
	var arg1 = deg_to_rad(player.aim_target.y)
	player.aim_target.y = rad_to_deg(rotate_toward(arg1, yaw, speed * delta))


func tween_rotate_player_to_pos(pos: Vector3, time: float) -> void:
	var dir = player.global_position - pos
	var target_angle = atan2(-dir.x, -dir.z)
	if rot_twn: rot_twn.kill()
	rot_twn = create_tween()
	await rot_twn.tween_property(player, "aim_target:y", rad_to_deg(target_angle), time).finished


func block_ads_concentration(t: float) -> void:
	if player.ads_timer >= t: player.ads_timer = t


func clamp_view(center: Vector3, pitch_max: float, yaw_max) -> void:
	player.aim_target.y = clamp(player.aim_target.y, center.y - pitch_max, center.y + pitch_max)
	player.aim_target.x = clamp(player.aim_target.x, center.x - yaw_max, center.x + yaw_max)


func handle_action_tooltip(action: String) -> void:
	was_gpad = player.p_inputs.is_gamepad
	ui_manager.tooltip.set_label(action, was_gpad)
	add_on_process(process_tooltip_display.bind(action), true)
	ui_manager.tooltip.display(true)


func process_tooltip_display(action: String) -> void:
	if was_gpad == player.p_inputs.is_gamepad: return
	was_gpad = player.p_inputs.is_gamepad
	ui_manager.tooltip.set_label(action, was_gpad)


func free_tool_tip() -> void:
	ui_manager.tooltip.display(false)
	clean_ui_process()
