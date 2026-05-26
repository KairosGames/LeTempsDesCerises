class_name GameState00 extends GameState

@onready var go_to_georges: CustomMaker = %GoToGeorges


func enter() -> void:
	curr_step = 0
	steps = [
		Step.new(set_player_for_onboarding, wait_voice, get_up),
		#Step.new()
	]
	run_steps()


func exit() -> void:
	pass


func set_player_for_onboarding() -> void:
	var spawn: Node3D = game_manager.player_spwaner
	player.initiate(spawn.global_position, spawn.global_rotation, false, false, Player.Posture.PRONE)
	player.set_for_onboarding()
	player.aim_target.x = -70.0


func get_up() -> void:
	await get_tree().create_timer(1.0).timeout
	await player.blink_effect.open_eyes_from_sleep()
	await get_tree().create_timer(2.0).timeout
	var twn: Tween = create_tween()
	twn.tween_property(player, "aim_target:x", 0.0, 0.7)
	player.play_cam_landing_effect(-0.2, 30.0, 1.0)
	player.prone_to_crouch(false, 1.0)
	await get_tree().create_timer(1.1).timeout
	player.play_cam_landing_effect(-0.2, 5.0, 0.5)
	player.crouch_to_stand(false, 0.5)
	await get_tree().create_timer(1.1).timeout
	player.can_use_move = true
	player.can_use_view = true


func go_for_georges() -> void:
	on_process = walk_forward.bind(delta_t, 4.0)
