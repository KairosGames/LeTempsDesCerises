class_name GameState02 extends GameState

@onready var francois_moved_pos: CustomMarker = %FrancoisMovedPos
@onready var woman_points: WomanPoints = %WomanPoints
@onready var women_arrival_point: CustomMarker = %WomenArrivalPoint
@onready var discussion_point: CustomMarker = %DiscussionPoint
@onready var louise_detection_area: EventArea = %LouiseDetectionArea


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
	francois.global_position = francois_moved_pos.global_position
	francois.global_rotation = francois_moved_pos.global_rotation
	francois.is_figthing = true
	player.global_position = discussion_point.global_position
	player.blink_effect.set_eyes_to_step(BlinkEffect.EyesStep.OPEN)
	player.give_or_drop_weapon(true)
	player.is_weapon_loaded = true
	ui_manager.hard_set_letter_box(false)


func lauch_first_phase() -> void:
	for woman: Npc in woman_points.women: woman.visible = false
	ui_manager.set_objective(true, null, "Defend the barricade alongside your comrades")
	# Set Spawners#############################################################################
	await wait(0.0)#60.0)


func allies_arrival() -> void:
	await wait_until(is_player_alive)
	player.can_die = false
	await wait_voice() # "Faites place ! Faites place !"
	lauch_women()
	louise_detection_area.monitoring = true
	player.can_play = false
	await run_to_destination(women_arrival_point)
	var target_point: Vector3 = women_arrival_point.global_position + women_arrival_point.basis.z
	var time_ratio: float = get_yaw_diff_ratio(target_point)
	await tween_rotate_player_to_yaw(women_arrival_point.global_rotation.y, 1.0 * time_ratio)
	var louise: Npc = woman_points.women[0]
	await wait_signal(louise_detection_area.tracked_npc_entered)
	francois.is_figthing = false
	await francois.rotate_yaw_to_pos_tween(louise.global_position, 0.4)
	await wait_voice() # "Oh regardez là bas, on est vernis ! Allez, les frangines, avec nous !"
	var rot_targ: Vector3 = francois_moved_pos.global_position + francois_moved_pos.basis.z
	await francois.rotate_yaw_to_pos_tween(rot_targ, 0.4)
	francois.is_figthing = true
	await wait_signal(louise.arrived_on_path_point)
	lay_down_weapon(true)
	await wait_signal(louise.arrived_on_path_destination)
	await wait(1.0)
	take_player_move_control(false)
	take_player_view_control(false)
	player.can_play = true
	ui_manager.launch_letter_box(false)
	lay_down_weapon(false)
	await wait(ui_manager.time_to_open_letter_box)
	# Cut Enemy Spawners ############################################################################
	# WAIT NOT ENNEMY    ############################################################################


func lauch_women() -> void:
	for woman: Npc in woman_points.women:
		woman.visible = true
		var p1: CustomMarker = woman_points.get_first_point(woman)
		var p2: CustomMarker = woman_points.get_second_point(woman)
		var path_points: Array[Node3D] = [p1, p2]
		woman.launch_movement_to_paths(path_points)


func launch_women_dialogue() -> void:
	pass
