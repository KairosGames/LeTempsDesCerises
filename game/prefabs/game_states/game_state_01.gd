class_name GameState01 extends GameState

signal player_tried_to_exit

@onready var go_to_barricade_area: EventArea = %GoToBarricadeArea
@onready var objective_point_barricade: CustomMarker = %ObjectivePointBarricade
@onready var return_to_barricade: EventArea = %ReturnToBarricadeArea
@onready var first_die_area: EventArea = %FirstDieArea
@onready var jules: Npc = %Jules

var kill_counter: int = 0
var it_is_time_to_die: bool


func enter() -> void:
	curr_step = 0
	steps = [
		Step.new(go_to_barricade, stay_into_barricade_area, go_to_first_die),
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


func go_to_barricade() -> void:
	ui_manager.set_objective(true, objective_point_barricade, "Go to the barricade")
	go_to_barricade_area.monitoring = true
	await wait_signal(go_to_barricade_area.player_entered)
	go_to_barricade_area.set_deferred("monitoring", false)
	ui_manager.set_objective(true, null, "Defend the barricade alongside your comrades")


func stay_into_barricade_area() -> void:
	return_to_barricade.monitoring = true
	return_to_barricade.player_entered.connect(on_player_exit_barricade_zone)
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
	var dir = player.global_position - target_point
	var target_angle = atan2(-dir.x, -dir.z)
	var time_ratio: float = inverse_lerp(0.0, PI, abs(wrapf(target_angle - player.global_rotation.y, -PI, PI)))
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
	await wait(120.0)
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
	await wait(player.death_camera.fall_time_1 + player.death_camera.fall_time_2)
	await wait_voice()


func can_player_die() -> bool:
	if player.curr_posture != Player.Posture.STAND: return false
	if player.p_inputs.is_game_controlling_movement: return false
	if player.p_inputs.is_game_controlling_view: return false
	return first_die_area.is_player_inside()
