class_name GameState02 extends GameState

@onready var woman_points: WomanPoints = %WomanPoints
@onready var women_arrival_point: CustomMarker = %WomenArrivalPoint
@onready var discussion_point: CustomMarker = %DiscussionPoint


func enter() -> void:
	curr_step = 0
	steps = [
		Step.new(lauch_first_phase, allies_arrival, launch_women_dialogue),
	]
	run_steps()
	if game_manager.use_debug: set_player_for_debug()


func exit() -> void:
	pass


func set_player_for_debug() -> void:
	player.global_position = discussion_point.global_position
	player.blink_effect.set_eyes_to_step(BlinkEffect.EyesStep.OPEN)
	player.give_or_drop_weapon(true)
	player.is_weapon_loaded = true
	ui_manager.hard_set_letter_box(false)


func lauch_first_phase() -> void:
	for woman: Npc in woman_points.women: woman.visible = false
	ui_manager.set_objective(true, null, "Defend the barricade alongside your comrades")
	# Set Spawners#############################################################################
	await wait(10.0)#60.0)


func allies_arrival() -> void:
	await wait_voice()
	lauch_women()
	await run_to_destination(women_arrival_point)
	var target_point: Vector3 = women_arrival_point.global_position + women_arrival_point.basis.z
	var time_ratio: float = get_yaw_diff_ratio(target_point)
	await tween_rotate_player_to_yaw(women_arrival_point.global_rotation.y, 1.0 * time_ratio)
	var louise: Npc = woman_points.women[0]
	await wait_until(is_npc_on_screen.bind(louise))
	print("C DEDAAAAAAAAAAAAAAAAAANSS !!")
	add_on_process(yaw_player_look_dest.bind(louise, PI * 2.0, delta_t))
	louise.arrived_on_path_destination.connect(clean_process, CONNECT_ONE_SHOT)
	await wait_signal(louise.arrived_on_path_destination)
	print("FINITO")
	await wait(1.0)
	take_player_move_control(false)
	take_player_view_control(false)
	player.can_play = true
	ui_manager.launch_letter_box(false)
	await wait(ui_manager.time_to_open_letter_box)
	# Cut Enemy Spawners############################################################################
	# WAIT NOT ENNEMY


func lauch_women() -> void:
	for woman: Npc in woman_points.women:
		woman.visible = true
		var p1: CustomMarker = woman_points.get_first_point(woman)
		var p2: CustomMarker = woman_points.get_second_point(woman)
		var path_points: Array[Node3D] = [p1, p2]
		woman.launch_movement_to_paths(path_points)


func launch_women_dialogue() -> void:
	pass
