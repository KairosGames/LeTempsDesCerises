class_name GameState01 extends GameState

@onready var go_to_barricade_area: EventArea = %GoToBarricadeArea
@onready var objective_point_barricade: Node3D = %ObjectivePointBarricade
@onready var return_to_barricade: EventArea = %ReturnToBarricadeArea
@onready var first_die_area: EventArea = %FirstDieArea

var kill_counter: int = 0
var it_is_time_to_die: bool


func enter() -> void:
	curr_step = 0
	steps = [
		#Step.new(set_player_for_debug, do_nothing, do_nothing),

		Step.new(go_to_barricade, stay_into_barricade_area, go_to_first_die),
	]
	run_steps()


func exit() -> void:
	pass


func go_to_barricade() -> void:
	ui_manager.set_objective(true, objective_point_barricade, "Go to the barricade")
	go_to_barricade_area.monitoring = true
	await wait_signal(go_to_barricade_area.player_entered)
	go_to_barricade_area.monitoring = false
	ui_manager.set_objective(true, null, "Defend the barricade alongside your comrades")


func stay_into_barricade_area() -> void:
	return_to_barricade.monitoring = true
	return_to_barricade.player_entered.connect(on_player_exit_barricade_zone)
	player.enemy_shot.connect(on_enemy_shot)
	launch_first_die_timer()
	await wait_until(is_it_time_to_die)


func on_player_exit_barricade_zone() -> void:
	player.can_play = false
	take_player_move_control(true)
	take_player_view_control(true)
	if player.is_running: player.is_running = false
	if player.is_aiming:
		player.is_aiming = false
		player.switch_aim_state()
	await tween_rotate_player_to_pos(objective_point_barricade.global_position, 0.35)
	set_player_move(Vector2(0.0, 1.0))
	await wait(1.0)
	take_player_move_control(false)
	take_player_view_control(false)
	player.can_play = true


func on_enemy_shot() -> void:
	kill_counter += 1


func launch_first_die_timer() -> void:
	await wait(120.0)
	it_is_time_to_die = true


func is_it_time_to_die() -> bool:
	return it_is_time_to_die or kill_counter >= 2


func go_to_first_die() -> void:
	player.enemy_shot.disconnect(on_enemy_shot)
	first_die_area.monitoring = true
	await wait_until(can_player_die)
	await wait(0.4)
	player.can_die = true
	player.die()
	return_to_barricade.player_entered.disconnect(on_player_exit_barricade_zone)
	return_to_barricade.monitoring = false
	first_die_area.monitoring = false


func can_player_die() -> bool:
	if player.curr_posture != Player.Posture.STAND: return false
	if player.p_inputs.is_game_controlling_movement: return false
	if player.p_inputs.is_game_controlling_view: return false
	return first_die_area.is_player_inside()
