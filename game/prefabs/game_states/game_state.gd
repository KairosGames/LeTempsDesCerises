@abstract class_name GameState extends Node

@onready var francois: Npc = %Francois
@onready var death_zone: EventArea = %DeathZone

@warning_ignore("unused_signal") signal completed
@warning_ignore("unused_signal") signal voice_line_finished

@abstract func enter() -> void
@abstract func exit() -> void
@abstract func set_game_for_debug() -> void
@abstract func set_short_timers() -> void

var steps: Array[Step] = []
var curr_step: int = 0
var is_active: bool = false

static var voice_line_index: int = -1
static var set_debug_applied: bool = false
var game_manager: GameManager
var eff_manager: EffectsManager
var ui_manager: UIManager
var battle_director: BattleDirector
var player: Player
var next_respawn: Npc
var on_process: Array[Callable]
var on_physics_process: Array[Callable]
var on_ui_process: Array[Callable]
var on_debug_process: Array[Callable]
var delta_t: float
var delta_ph: float
var local_bool: bool
var was_gpad: bool
var is_nav_finished: bool = false

var rot_twn: Tween


func _ready() -> void:
	ready_deffered.call_deferred()


func ready_deffered() -> void:
	game_manager = GameManager.instance
	if Player.instance: player = Player.instance
	else: game_manager.player_instance_loaded.connect(set_local_player, CONNECT_ONE_SHOT)
	eff_manager = EffectsManager.instance
	ui_manager = UIManager.instance
	battle_director = BattleDirector.instance
	death_zone.monitoring = true
	death_zone.player_entered.connect(kill_player)


func set_local_player() -> void:
	player = Player.instance


func _process(delta: float) -> void:
	if not is_active: return
	delta_t = delta
	for callable: Callable in on_process: callable.call()
	for callable: Callable in on_ui_process: callable.call()
	for callable: Callable in on_debug_process: callable.call()
	
	####### FOR DEBUG
	debug_process(delta)


func _physics_process(delta: float) -> void:
	delta_ph = delta
	for callable: Callable in on_physics_process: callable.call()


func run_steps() -> void:
	for step: Step in steps:
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


func add_on_process(callable: Callable, is_ui: bool = false) -> void:
	if is_ui:
		on_ui_process.push_back(callable)
		return
	on_process.push_back(callable)


func add_on_physics_process(callable: Callable) -> void:
	on_physics_process.push_back(callable)


func add_on_debug_process(callable: Callable) -> void:
	on_debug_process.push_back(callable)

func clean_process() -> void:
	on_process.clear()


func clean_physics_process() -> void:
	on_physics_process.clear()


func clean_ui_process() -> void:
	on_ui_process.clear()


func clean_debug_process() -> void:
	on_debug_process.clear()


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
	print("WAIT VOICE, i : ", voice_line_index)
	game_manager.voice_line_called.emit(voice_line_index)
	await voice_line_finished


func call_voice() -> void:
	voice_line_index += 1
	game_manager.voice_line_called.emit(voice_line_index)


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


func yaw_player_look_dest(destination: Node3D, speed: float, delta: float) -> void:
	var dir = player.global_position - destination.global_position
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
	var delta: float = wrapf(rad_to_deg(target_angle) - player.aim_target.y, -180.0, 180.0)
	await rot_twn.tween_property(player, "aim_target:y", delta, time).as_relative().finished


func tween_rotate_player_to_yaw(yaw: float, time: float) -> void:
	if rot_twn: rot_twn.kill()
	rot_twn = create_tween()
	var delta: float = wrapf(rad_to_deg(yaw) - player.aim_target.y, -180.0, 180.0)
	await rot_twn.tween_property(player, "aim_target:y", delta, time).as_relative().finished


func get_input_dir_to_pos(pos: Vector3) -> Vector2:
	var world_dir: Vector3 = (pos - player.global_position).normalized()
	var local_dir: Vector3 = player.global_basis.inverse() * world_dir
	var input_dir: Vector2 = Vector2(local_dir.x, local_dir.z).normalized()
	return input_dir


func get_yaw_diff_ratio(target_point: Vector3) -> float:
	var dir = player.global_position - target_point
	var target_angle = atan2(-dir.x, -dir.z)
	return inverse_lerp(0.0, PI, abs(wrapf(target_angle - player.global_rotation.y, -PI, PI)))


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


func is_player_alive() -> bool:
	return player.is_alive


func kill_player() -> void:
	player.can_die = true
	player.is_immortal = false
	player.die()


func run_to_destination(destination: Node3D) -> void:
	take_player_move_control(true)
	take_player_view_control(true)
	add_on_debug_process(use_nav_debug) ## FOR DBUG
	ui_manager.launch_letter_box(true)
	player.nav.target_position = destination.global_position
	set_player_for_cinematic()
	add_on_physics_process(go_to_nav_destination)
	await wait_until(is_player_on_nav_destination)
	var input_dir: Vector2 = get_input_dir_to_pos(destination.global_position)
	set_player_move(input_dir)
	await wait_until(is_player_on_position.bind(destination))
	set_player_move(Vector2.ZERO)
	clean_debug_process() ## FOR DBUG


func set_player_for_cinematic() -> void:
	var twn: Tween = create_tween()
	twn.tween_property(player, "aim_target:x", 0.0, 0.3)
	leave_reload()
	leave_aim()
	await wait(player.state_switch_time + 0.1)
	if player.curr_posture == Player.Posture.CROUCH: player.crouch_to_stand()
	if player.curr_posture == Player.Posture.PRONE: player.prone_to_stand()
	if player.is_reloading: player.exit_reload()


func leave_aim() -> void:
	if player.is_aiming:
		player.is_aiming = false
		player.switch_aim_state()


func leave_reload() -> void:
	if player.is_reloading: player.exit_reload(false)


func go_to_nav_destination(run: bool = true) -> void:
	#######FOR DEBUG
	if detect_input_debug():
		set_player_move(Vector2(0.0, 0.0))
		player.is_running = false
		return
	if player.nav.is_navigation_finished():
		set_player_move(Vector2(0.0, 0.0))
		player.is_running = false
		clean_physics_process()
		is_nav_finished = true
		return
	var next_pos: Vector3 = player.nav.get_next_path_position()
	rotate_yaw_player_to_pos(next_pos, PI * 2, delta_ph)
	var dir = player.global_position - next_pos
	var target_angle = atan2(-dir.x, -dir.z)
	if abs(wrapf(player.global_rotation.y - target_angle, -PI, PI)) < PI * 0.1:
		set_player_move(Vector2(0.0, 1.0))
		if run:
			player.is_running = true
	else:
		set_player_move(Vector2(0.0, 0.0))
		player.is_running = false


func is_player_on_nav_destination() -> bool:
	return is_nav_finished


func is_player_on_position(pos: Node3D) -> bool:
	return player.global_position.distance_squared_to(pos.global_position) <= 0.05


func is_npc_out_of_screen(npc: Npc) -> bool:
	if npc.is_on_screen.is_on_screen(): return false
	return true


func is_npc_on_screen(npc: Npc) -> bool:
	if not npc.is_on_screen.is_on_screen(): return false
	return true


func lay_down_weapon(is_down: bool) -> void:
	var trans: Tween.TransitionType = Tween.TransitionType.TRANS_QUAD if is_down else Tween.TransitionType.TRANS_QUART
	var ea: Tween.EaseType = Tween.EaseType.EASE_OUT if is_down else Tween.EaseType.EASE_IN
	var targ: Node3D = player.reload_pos_right if player.is_right_handed else player.reload_pos_left
	var targ_pos: Vector3 = targ.position if is_down else Vector3.ZERO
	var targ_rot: Vector3 = targ.rotation if is_down else Vector3.ZERO
	var twn: Tween = create_tween()
	twn.tween_property(player.reload_root, "position", targ_pos, 1.0
					).set_trans(trans).set_ease(ea)
	twn.parallel().tween_property(player.reload_root, "rotation", targ_rot, 1.0
					).set_trans(trans).set_ease(ea)
	await twn.finished


func is_there_no_enemies() -> bool:
	var are_all_dead: bool = true
	for ennemy: Agent in get_tree().get_nodes_in_group("Versaillais"):
		if ennemy.is_alive: are_all_dead = false
	return are_all_dead


func is_there_one_ally() -> bool:
	var list: Array[Node] = get_tree().get_nodes_in_group("Communard").filter(func(o): return o is not Player)
	var alive_count: int = 0
	for ally: Agent in list:
		if ally.is_alive: alive_count += 1
	return alive_count <= 1


func is_there_no_allies() -> bool:
	var list: Array[Node] = get_tree().get_nodes_in_group("Communard").filter(func(o): return o is not Player)
	var are_all_dead: bool = true
	for ally: Agent in list:
		if ally.is_alive: are_all_dead = false
	return are_all_dead


func set_active_agents(are_allies: bool, enable: bool, aiming: bool = false) -> void:
	var group: String = "Communard" if are_allies else "Versaillais"
	var list: Array = get_tree().get_nodes_in_group(group)
	if are_allies: list = list.filter(func(o): return o is not Player)
	for agent: Agent in list:
		agent.is_disabled = not enable
		agent.posture = Agent.Posture.STAND
		print("ALLY : ", are_allies)
		print("DISABLE : ", agent.is_disabled)
		if aiming and not enable: agent.is_aiming = true


func disable_all_spawners() -> void:
	var spawners: Array = get_tree().get_nodes_in_group("Spawners")
	for spawner: Cover in spawners: spawner.enabled = false


func set_visible_all_agents(is_visible: bool) -> void:
	var agents: Array = get_tree().get_nodes_in_group("Communard").filter(func(o): return o is not Player)
	agents.append_array(get_tree().get_nodes_in_group("Versaillais"))
	for agent: Agent in agents: agent.visible = is_visible


##################### FOR DEBUG ##############################
func debug_process(_delta: float) -> void:
	if Input.is_action_just_pressed("go_next_step") and game_manager.is_game_playing() and game_manager.use_narrative:
		print("NEXT CALLED")
		voice_line_finished.emit()

func add_worker_on_cannon() -> void:
	if Input.is_action_just_pressed("choice_surrender"):
		game_manager.cannon._create_workers(1)


func kill_agents(kill_enemies: bool, kill_allies: bool) -> void:
	if Input.is_action_just_pressed("go_next_step"):
		if kill_enemies:
			for versaillais: Agent in get_tree().get_nodes_in_group("Versaillais"):
				versaillais.die()
		if kill_allies:
			for communard: Agent in get_tree().get_nodes_in_group("Communard").filter(func(v): return v is not Player):
				communard.die()
		clean_process()
	if is_there_no_enemies() and kill_enemies: clean_process()
	if is_there_no_allies() and kill_allies: clean_process()


func detect_input_debug() -> bool:
	return Input.is_action_pressed("nav_debug_back") \
			or Input.is_action_pressed("nav_debug_left") \
			or Input.is_action_pressed("nav_debug_right") 


func kill_versaillais_on_cannon() -> void:
	for agent: Agent in game_manager.cannon.workers:
			if not agent or not is_instance_valid(agent): continue
			agent.die()


func use_nav_debug() -> void:
	if Input.is_action_pressed("nav_debug_back"): set_player_move(Vector2(0.0, -1.0))
	if Input.is_action_pressed("nav_debug_left"): set_player_move(Vector2(-1.0, 0.0))
	if Input.is_action_pressed("nav_debug_right"): set_player_move(Vector2(1.0, 0.0))
##################### FOR DEBUG ##############################
