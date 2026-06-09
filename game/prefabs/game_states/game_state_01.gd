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

var kill_counter: int = 0
var it_is_time_to_die: bool = false


func enter() -> void:
	curr_step = 0
	steps = [
		Step.new(go_to_barricade, stay_into_barricade_area, go_to_first_die),
		Step.new(do_nothing, lauch_first_battle_phase, do_nothing),
		Step.new(do_nothing, launch_canon_arrival, do_nothing),
		Step.new(go_to_cover_from_canon, launch_first_canon_shoot, do_nothing),
		Step.new(do_nothing, lauch_second_battle_phase, do_nothing),
	]
	run_steps()
	if game_manager.use_debug: set_player_for_debug()


func exit() -> void:
	pass


func set_player_for_debug() -> void:
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
	if player.is_aiming:
		player.is_aiming = false
		player.switch_aim_state()
	var target_point: Vector3 = player.global_position + return_to_barricade.basis.x
	var time_ratio: float = get_yaw_diff_ratio(target_point)
	await tween_rotate_player_to_pos(target_point, 1.0 * time_ratio)
	set_player_move(Vector2(0.0, 1.0))
	await wait(0.5)
	take_player_move_control(false)
	take_player_view_control(false)
	player.can_play = true
	ui_manager.launch_letter_box(false)


func on_enemy_shot() -> void:
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
	await wait(120.0)


func launch_canon_arrival() -> void:
	# Call the canon
	await wait_voice()
	ui_manager.set_objective(true, null, "Stop the cannon from destroying the barricade") #give canon here to the target
	# Check if player kill a enemy on the canon and give null target to set objective
	# Wait canon signal ready_to_shot


func go_to_cover_from_canon() -> void:
	await wait_until(is_player_alive)
	player.can_die = false
	await wait_voice()
	ui_manager.set_objective(true, null, "Take cover from the cannon fire")
	player.can_play = false
	var dist1: float = player.global_position.distance_squared_to(canon_shoot_cover1.global_position)
	var dist2: float = player.global_position.distance_squared_to(canon_shoot_cover2.global_position)
	var cover: CustomMarker = canon_shoot_cover1 if dist1 < dist2 else canon_shoot_cover2
	take_player_move_control(true)
	take_player_view_control(true)
	ui_manager.launch_letter_box(true)
	player.nav.target_position = cover.global_position
	go_to_stand_posture()
	var twn: Tween = create_tween()
	twn.tween_property(player, "aim_target:x", 0.0, 0.3)
	add_on_physics_process(go_to_canon_cover)
	await wait_until(is_player_on_nav_destination)
	var input_dir: Vector2 = get_input_dir_to_pos(cover.global_position)
	set_player_move(input_dir)
	await wait_until(is_player_on_canon_shoot_cover.bind(cover))
	set_player_move(Vector2.ZERO)
	var target_point: Vector3 = cover.global_position + return_to_barricade.basis.z
	var time_ratio: float = get_yaw_diff_ratio(target_point)
	await tween_rotate_player_to_yaw(cover.global_rotation.y, 1.0 * time_ratio)
	player.crouch_to_stand(true)
	await wait(player.state_switch_time)


func is_player_on_nav_destination() -> bool:
	return is_nav_mesh_finished


func is_player_on_canon_shoot_cover(cover: CustomMarker) -> bool:
	return player.global_position.distance_squared_to(cover.global_position) <= 0.1


func go_to_stand_posture() -> void:
	await wait(player.state_switch_time + 0.1)
	if player.curr_posture == Player.Posture.CROUCH: player.crouch_to_stand()
	if player.curr_posture == Player.Posture.PRONE: player.prone_to_stand()


func go_to_canon_cover() -> void:
	if player.nav.is_navigation_finished():
		set_player_move(Vector2(0.0, 0.0))
		player.is_running = false
		clean_physics_process()
		is_nav_mesh_finished = true
		return
	var next_pos: Vector3 = player.nav.get_next_path_position()
	rotate_yaw_player_to_pos(next_pos, PI * 2, delta_ph)
	var dir = player.global_position - next_pos
	var target_angle = atan2(-dir.x, -dir.z)
	print(target_angle)
	if abs(wrapf(player.global_rotation.y - target_angle, -PI, PI)) < PI * 0.1:
		set_player_move(Vector2(0.0, 1.0))
		player.is_running = true
	else:
		set_player_move(Vector2(0.0, 0.0))
		player.is_running = false


func launch_first_canon_shoot() -> void:
	game_ready_canon_shoot.emit()
	# Camera Shake (MDR)
	
	#if Input.is_action_just_pressed("go_next_step"):
		#wpn_cam_base.shake(1.0, 1.0, 1.0)
	
	# Kill allies arround barricade ?? (maybe make it directly on the barricade would be better)
	# Put François behind the second barricade if we dont see him (maybe later ??)
	# Give player control
	ui_manager.set_objective(true, null, "Defend the barricade alongside your comrades")


func lauch_second_battle_phase() -> void:
	# Set spwaners
	# Wait barricade destruction
	ui_manager.set_objective(true, null, "Go to the backup barricade") #give second barricade here to the target
	# Activate death zone near of the second barricade
	call_enemies_enter()
	# Wait player death and make it respawn on a chosen NPC


func call_enemies_enter() -> void:
	await wait(20.0)
	# Activate ennemies covers
