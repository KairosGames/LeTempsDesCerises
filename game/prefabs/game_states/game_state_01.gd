class_name GameState01 extends GameState

signal player_tried_to_exit
signal game_ready_canon_shoot

@onready var go_to_barricade_area: EventArea = %GoToBarricadeArea
@onready var objective_point_barricade: CustomMarker = %ObjectivePointBarricade
@onready var return_to_barricade: EventArea = %ReturnToBarricadeArea
@onready var first_die_area: EventArea = %FirstDieArea
@onready var invisible_wall_barricade: StaticBody3D = %InvisibleWallBarricade
@onready var jules: Npc = %Jules
@onready var canon_shoot_cover1: CustomMarker = %CanonShootCover1
@onready var canon_shoot_cover2: CustomMarker = %CanonShootCover2
@onready var canon_detection_area: EventArea = %CanonDetectionArea
@onready var francois_moved_pos: CustomMarker = %FrancoisMovedPos
@onready var second_barricade_npc: Npc = %SecondBarricadeNPC
@onready var go_to_second_barricade: CustomMarker = %GoToSecondBarricade
@onready var death_zone_second_barricade: EventArea = %DeathZoneSecondBarricade

var kill_counter: int = 0
var it_is_time_to_die: bool = false


func enter() -> void:
	curr_step = 0
	steps = [
		Step.new(go_to_barricade, stay_into_barricade_area, go_to_first_die),
		Step.new(do_nothing, lauch_first_battle_phase, do_nothing),
		Step.new(do_nothing, launch_canon_arrival, do_nothing),
		Step.new(go_to_cover_from_canon, launch_first_canon_shoot, do_nothing),
		Step.new(lauch_second_battle_phase, wait_francois_move, wait_barricade_destruction),
		Step.new(enemies_enter_first_zone, do_nothing, do_nothing),
	]
	run_steps()
	if game_manager.use_debug: set_player_for_debug()


func exit() -> void:
	pass


func set_player_for_debug() -> void:
	ui_manager.set_objective(true, game_manager.all_states[0].objective_point_barricade, "Go to the barricade")
	player.blink_effect.set_eyes_to_step(BlinkEffect.EyesStep.OPEN)
	player.give_or_drop_weapon(true)
	player.is_weapon_loaded = true
	ui_manager.hard_set_letter_box(false)
	player.can_die = false


func go_to_barricade() -> void:
	go_to_barricade_area.monitoring = true
	player.can_use_run = true
	handle_action_tooltip("run")
	add_on_process(check_run)
	await wait_signal(go_to_barricade_area.player_entered)
	clean_ui_process()
	go_to_barricade_area.set_deferred("monitoring", false)
	ui_manager.set_objective(true, null, "Defend the barricade alongside your comrades")


func check_run() -> void:
	if player.is_running:
		free_tool_tip()
		clean_ui_process()
		clean_process()


func stay_into_barricade_area() -> void:
	invisible_wall_barricade.process_mode = Node.PROCESS_MODE_INHERIT
	return_to_barricade.monitoring = true
	return_to_barricade.player_entered.connect(on_player_exit_barricade_zone)
	call_voice()
	player.enemy_shot.connect(on_enemy_shot)
	launch_first_die_timer()
	await wait_until(is_it_time_to_die)
	player.enemy_shot.disconnect(on_enemy_shot)
	await wait_voice()


func on_player_exit_barricade_zone() -> void:
	player_tried_to_exit.emit()
	player.can_play = false
	ui_manager.launch_letter_box(true)
	take_player_move_control(true)
	take_player_view_control(true)
	if player.is_running: player.is_running = false
	leave_aim()
	var target_point: Vector3 = player.global_position + return_to_barricade.basis.x
	var time_ratio: float = get_yaw_diff_ratio(target_point)
	await tween_rotate_player_to_pos(target_point, 1.0 * time_ratio)
	set_player_move(Vector2(0.0, 1.0))
	await wait(0.5)
	take_player_move_control(false)
	take_player_view_control(false)
	player.can_play = true
	ui_manager.launch_letter_box(false)


func on_enemy_shot(_target: Node3D) -> void:
	kill_counter += 1


func launch_first_die_timer() -> void:
	await wait(60.0)
	it_is_time_to_die = true


func is_it_time_to_die() -> bool:
	return it_is_time_to_die or kill_counter >= 2


func go_to_first_die() -> void:
	first_die_area.monitoring = true
	await wait_until(can_player_die)
	await wait(0.3)
	player.can_die = true
	next_respawn = jules
	player.die(true)
	return_to_barricade.player_entered.disconnect(on_player_exit_barricade_zone)
	return_to_barricade.monitoring = false
	first_die_area.monitoring = false
	invisible_wall_barricade.process_mode = Node.PROCESS_MODE_DISABLED
	await wait(player.death_camera.fall_time_1 + player.death_camera.fall_time_2)
	await wait_voice()


func can_player_die() -> bool:
	if player.curr_posture != Player.Posture.STAND: return false
	if player.p_inputs.is_game_controlling_movement: return false
	if player.p_inputs.is_game_controlling_view: return false
	return first_die_area.is_player_inside()
	
	
func lauch_first_battle_phase() -> void:
	# Set spwaners ##########################################################################################
	print("WAIT 90S")
	await wait(90.0)


func launch_canon_arrival() -> void:
	print("CANON ACTIVATED")
	game_manager.canon.enabled = true
	canon_detection_area.monitoring = true
	await wait_signal(canon_detection_area.canon_entered)
	canon_detection_area.set_deferred("monitoring", false)
	print("CANON ENTERED WAIT VOICE")
	await wait_voice() # "Ils ont un bronze!"
	ui_manager.set_objective(true, game_manager.canon, "Stop the cannon from destroying the barricade")
	player.enemy_shot.connect(check_player_kill_canon_enemy)
	await wait_until_or_signal(is_canon_ready_to_shoot, game_manager.canon.reloaded)
	for agent: Agent in game_manager.canon.workers: agent.can_die = false
	if player.enemy_shot.is_connected(check_player_kill_canon_enemy): player.enemy_shot.disconnect(check_player_kill_canon_enemy)
	ui_manager.objective_target.target = null


func is_canon_ready_to_shoot() -> bool:
	return game_manager.canon.reload_progress >= 1.0


func check_player_kill_canon_enemy(target: Node3D) -> void:
	if not target is Agent : return
	var versaillais: Agent = target as Agent
	if versaillais.team != Agent.Team.VERSAILLAIS: return
	if not versaillais.get_parent(): return
	if not versaillais.canon_slot: return
	if versaillais.get_parent() == versaillais.canon_slot:
		ui_manager.objective_target.target = null
		player.enemy_shot.disconnect(check_player_kill_canon_enemy)


func go_to_cover_from_canon() -> void:
	await wait_until(is_player_alive)
	player.can_die = false
	await wait_voice() # "Attention, ils vont tirer au canon !"
	ui_manager.set_objective(true, null, "Take cover from the cannon fire")
	player.can_play = false
	var dist1: float = player.global_position.distance_squared_to(canon_shoot_cover1.global_position)
	var dist2: float = player.global_position.distance_squared_to(canon_shoot_cover2.global_position)
	var cover: CustomMarker = canon_shoot_cover1 if dist1 < dist2 else canon_shoot_cover2
	await run_to_destination(cover)
	var target_point: Vector3 = cover.global_position + cover.basis.z
	var time_ratio: float = get_yaw_diff_ratio(target_point)
	await tween_rotate_player_to_yaw(cover.global_rotation.y, 1.0 * time_ratio)
	player.crouch_to_stand(true)
	await wait(player.state_switch_time)


func launch_first_canon_shoot() -> void:
	game_ready_canon_shoot.emit()
	await wait_signal(game_manager.first_barricade.state_changed)
	player.wpn_cam_base.shake(1.0, 1.0, 1.0)
	for agent: Agent in game_manager.canon.workers: agent.can_die = true
	await wait_voice() # "Putain, ils ont pété la barricade"
	take_player_move_control(false)
	take_player_view_control(false)
	player.can_play = true
	ui_manager.launch_letter_box(false)
	await wait(ui_manager.time_to_open_letter_box)


func lauch_second_battle_phase() -> void:
	ui_manager.set_objective(true, null, "Defend the barricade alongside your comrades")
	# Set spwaners ##########################################################################################


func wait_francois_move() -> void:
	await wait_until(is_npc_out_of_screen.bind(francois))
	francois.global_position = francois_moved_pos.global_position
	francois.global_rotation = francois_moved_pos.global_rotation


func wait_barricade_destruction() -> void:
	await wait_until_or_signal(is_first_barricade_destroyed, game_manager.first_barricade.just_destroyed)
	game_manager.canon.enabled = false


func is_first_barricade_destroyed() -> bool:
	return game_manager.first_barricade.is_destroyed


func enemies_enter_first_zone() -> void:
	ui_manager.set_objective(true, go_to_second_barricade, "Go to the backup barricade") # give second baricade target
	await wait(20.0)
	# Set spwaners #################################################################################################
	player.is_next_death_scripted = true
	next_respawn = second_barricade_npc
	death_zone_second_barricade.player_entered.connect(kill_player, CONNECT_ONE_SHOT)
	death_zone_second_barricade.monitoring = true
	await wait_signal(player.died)
	ui_manager.objective_target.target = null
	canon_detection_area.set_deferred("monitoring", false)
	if death_zone_second_barricade.player_entered.is_connected(kill_player): death_zone_second_barricade.player_entered.disconnect(kill_player)
