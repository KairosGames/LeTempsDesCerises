class_name GameState00 extends GameState

@onready var georges_rdv: CustomMaker = %GeorgesRDV
@onready var georges: Npc = %Georges


func enter() -> void:
	curr_step = 0
	steps = [
		Step.new(set_player_for_onboarding, wait_voice, get_up),
		Step.new(go_for_georges, wait_voice, take_weapon),
		Step.new(wait_voice, wait.bind(10.0), do_nothing)
	]
	run_steps()


func exit() -> void:
	pass


func set_player_for_onboarding() -> void:
	var spawn: CustomMaker = game_manager.player_spawner
	player.initiate(spawn.global_position, spawn.global_rotation, false, false, Player.Posture.PRONE)
	player.set_for_onboarding()
	player.aim_target.x = -70.0


func get_up() -> void:
	await wait(1.0)
	await player.blink_effect.open_eyes_from_sleep()
	await wait(2.0)
	var twn: Tween = create_tween()
	twn.tween_property(player, "aim_target:x", 0.0, 0.7)
	player.play_cam_landing_effect(-0.2, 30.0, 1.0)
	player.prone_to_crouch(false, 1.0)
	await wait(1.1)
	player.play_cam_landing_effect(-0.2, 5.0, 0.5)
	player.crouch_to_stand(false, 0.5)
	await wait(1.1)


func go_for_georges() -> void:
	take_player_move_control(true)
	set_player_move(Vector2(0.0, 0.5))
	await wait(0.3)
	take_player_view_control(true)
	on_process = rotate_player_to_pos.bind(georges_rdv.global_position, PI/8.0, delta_t)
	await wait(2.0)
	clean_process()
	await wait_until(func(): return player.global_position.distance_squared_to(georges_rdv.global_position) <= 0.1)
	take_player_move_control(false)
	on_process = rotate_player_to_pos.bind(georges.global_position, PI/4.0, delta_t)
	await wait(1.0)
	clean_process()
	take_player_view_control(false)


func take_weapon() -> void:
	take_player_view_control(true)
	on_process = rotate_player_to_yaw.bind(georges_rdv.rotation, PI/4.0, delta_t)
