@abstract class_name GameState extends Node

@warning_ignore("unused_signal") signal completed
@warning_ignore("unused_signal") signal voice_line_finished

@abstract func enter() -> void
@abstract func exit() -> void

var steps: Array[Step] = []
var curr_step: int = 0

var game_manager: GameManager
var eff_manager: EffectsManager
var player: Player
var on_process: Callable
var delta_t: float
var voice_line_index: int = -1
var local_bool: bool

func _ready() -> void:
	ready_deffered.call_deferred()


func ready_deffered() -> void:
	on_process = do_nothing
	game_manager = GameManager.instance
	eff_manager = EffectsManager.instance
	player = Player.instance


func _process(delta: float) -> void:
	delta_t = delta
	on_process.call()
	if Input.is_action_just_pressed("go_next_step"):
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


func do_nothing(_p: float = 0.0) -> void:
	pass


func wait(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout


func wait_until(condition: Callable) -> void:
	while not condition.call():
		await get_tree().process_frame


func wait_signal(signal_to_wait: Signal) -> void:
	await signal_to_wait


func wait_until_or_signal(condition: Callable, signal_to_wait: Signal) -> void:
	local_bool = false
	signal_to_wait.connect(func(): local_bool = true, CONNECT_ONE_SHOT)
	while not local_bool:
		local_bool = condition.call()
		await get_tree().process_frame


func wait_voice() -> void:
	voice_line_index += 1
	await voice_line_finished


func set_on_process(callable: Callable) -> void:
	on_process = callable


func clean_process() -> void:
	on_process = do_nothing


func take_player_move_control(is_taken: bool) -> void:
	player.p_inputs.is_game_controlling_movement = is_taken
	player.p_inputs.move_vec = Vector2.ZERO


func take_player_view_control(is_taken: bool) -> void:
	player.p_inputs.is_game_controlling_view = is_taken
	player.p_inputs.aim_vec_gamepad = Vector2.ZERO
	player.p_inputs.aim_vec_mouse = Vector2.ZERO


func set_player_move(dir: Vector2) -> void:
	player.p_inputs.move_vec = dir.normalized()


func rotate_player_to_pos(pos: Vector3, speed: float, delta: float) -> void:
	var dir = player.global_position - pos
	var target_angle = atan2(-dir.x, -dir.z)
	var arg1 = deg_to_rad(player.aim_target.y)
	player.aim_target.y = rad_to_deg(rotate_toward(arg1, target_angle, speed * delta))


func rotate_player_to_yaw(yaw: float, speed: float, delta: float) -> void:
	var arg1 = deg_to_rad(player.aim_target.y)
	player.aim_target.y = rad_to_deg(rotate_toward(arg1, yaw, speed * delta))


func block_ads_concentration(t: float) -> void:
	if player.ads_timer >= t: player.ads_timer = t
