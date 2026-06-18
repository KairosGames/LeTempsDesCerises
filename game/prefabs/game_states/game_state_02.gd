class_name GameState02 extends GameState

@onready var francois_moved_pos: CustomMarker = %FrancoisMovedPos
@onready var desactivable_barricade: StaticBody3D = %DesactivableBarricade
@onready var woman_points: WomanPoints = %WomanPoints
@onready var women_arrival_point: CustomMarker = %WomenArrivalPoint
@onready var discussion_point: CustomMarker = %DiscussionPoint
@onready var louise_detection_area: EventArea = %LouiseDetectionArea
@onready var discussion_area: EventArea = %DiscussionArea
@onready var barricade_point: CustomMarker = %BarricadePoint

var first_battle_phase_time: float = 60.0


func enter() -> void:
	curr_step = 0
	steps = [
		Step.new(lauch_first_phase, allies_arrival, do_nothing),
		Step.new(launch_dialogue_preparation, launch_women_dialogue, do_nothing),
		Step.new(launch_last_battle_phase, do_nothing, do_nothing),
	]
	if game_manager.use_debug and not set_debug_applied: set_game_for_debug()
	if game_manager.use_short_time: set_short_timers()
	run_steps()


func exit() -> void:
	pass


func set_game_for_debug() -> void:
	for i: int in range(8): battle_director.go_next_covers_activation()
	voice_line_index = 22
	francois.global_position = francois_moved_pos.global_position
	francois.global_rotation = francois_moved_pos.global_rotation
	francois.is_fighting = true
	player.global_position = discussion_point.global_position
	player.blink_effect.set_eyes_to_step(BlinkEffect.EyesStep.OPEN)
	player.give_or_drop_weapon(true)
	player.is_weapon_loaded = true
	ui_manager.hard_set_letter_box(false)
	game_manager.cannon._is_first_shoot = false
	if game_manager.curr_barricade == game_manager.first_barricade:
		for i: int in range(0,3): game_manager.handle_cannon_shoot()
	set_debug_applied = true


func set_short_timers() -> void:
	first_battle_phase_time = 0.0


func lauch_first_phase() -> void:
	for woman: Npc in woman_points.women: woman.visible = false
	ui_manager.set_objective(true, null, "Defend the barricade alongside your comrades")
	print("ENTER WAIT")
	print(first_battle_phase_time)
	await wait(first_battle_phase_time)
	print("FINISH WAITING")


func allies_arrival() -> void:
	battle_director.go_next_covers_activation() ####################################### Arrivée des alliées
	await wait_until(is_player_alive)
	player.can_die = false
	await wait_voice() # "Faites place ! Faites place !"
	desactivable_barricade.process_mode = Node.PROCESS_MODE_DISABLED
	player.can_play = false
	await run_to_destination(women_arrival_point)
	launch_women()
	louise_detection_area.monitoring = true
	var target_point: Vector3 = women_arrival_point.global_position + women_arrival_point.basis.z
	var time_ratio: float = get_yaw_diff_ratio(target_point)
	await tween_rotate_player_to_yaw(women_arrival_point.global_rotation.y, 1.0 * time_ratio)
	var louise: Npc = woman_points.women[0]
	await wait_signal(louise_detection_area.tracked_npc_entered)
	louise_detection_area.set_deferred("monitoring", false)
	launch_francois_replique_on_women_arrival()
	await wait_signal(louise.arrived_on_path_point)
	desactivable_barricade.process_mode = Node.PROCESS_MODE_INHERIT
	lay_down_weapon(true)
	await wait_until_or_signal(louise.is_on_all_nav_finished, louise.arrived_on_path_destination)
	await wait(1.0)
	take_player_move_control(false)
	take_player_view_control(false)
	player.can_play = true
	ui_manager.launch_letter_box(false)
	lay_down_weapon(false)
	await wait(ui_manager.time_to_open_letter_box)

	#############################################################################FOR DEBUG
	add_on_process(kill_agents.bind(true, false))
	
	for agent: Agent in game_manager.cannon.workers:
		if not agent or not is_instance_valid(agent): continue
		agent.die()
	await wait_until(is_there_no_enemies)


func launch_women() -> void:
	for woman: Npc in woman_points.women:
		woman.visible = true
		var p1: CustomMarker = woman_points.get_first_point(woman)
		var p2: CustomMarker = woman_points.get_second_point(woman)
		var path_points: Array[Node3D] = [p1, p2]
		var speed: float = randf_range(3.7, 4.3)
		if woman.npc_name != Npc.NpcName.Louise: woman.collider.disabled = true
		await wait(0.05)
		woman.launch_movement_to_paths(path_points, speed, true)


func launch_francois_replique_on_women_arrival() -> void:
	var louise: Npc = woman_points.women[0]
	francois.is_fighting = false
	await francois.rotate_yaw_to_pos_tween(louise.global_position, 0.4)
	await wait_voice() # "Oh regardez là bas, on est vernis ! Allez, les frangines, avec nous !"
	var rot_targ: Vector3 = francois_moved_pos.global_position + francois_moved_pos.basis.z
	await francois.rotate_yaw_to_pos_tween(rot_targ, 0.4)
	francois.is_fighting = true


func launch_dialogue_preparation() -> void:
	francois.is_fighting = false
	for woman: Npc in woman_points.women: woman.is_fighting = false
	await wait_voice() #"On les a rétamés !"
	var louise: Npc = woman_points.women[0]
	var marie: Npc = woman_points.women[1]
	louise.rotate_yaw_to_pos_tween(discussion_point.global_position, 0.5)
	marie.rotate_yaw_to_pos_tween(discussion_point.global_position, 0.3)
	francois.launch_movement_to_nav_point(discussion_point, 2.0)
	await wait_signal(francois.arrived_on_path_destination)


func launch_women_dialogue() -> void:
	discussion_area.monitoring = true
	ui_manager.set_objective(true, discussion_area, "Check out the news from your Place Blanche's comrades")
	await wait_signal(discussion_area.player_entered)
	for woman: Npc in woman_points.women:
		var t: float = randf_range(0.5, 1.0)
		woman.rotate_yaw_to_pos_tween(discussion_point.global_position, t)
	ui_manager.objective_target.target = null
	discussion_area.set_deferred("monitoring", false)
	await wait_voice() # "Vous arrivez d'où comme ça ?"


func launch_last_battle_phase() -> void:
	battle_director.go_next_covers_activation() ####################################### Fin de l'accalmie
	var louise: Npc = woman_points.women[0]
	for woman: Npc in woman_points.women:
		var t: float = randf_range(0.5, 0.8)
		woman.rotate_yaw_to_pos_tween(barricade_point.global_position, t)
	await francois.rotate_yaw_to_pos_tween(barricade_point.global_position, 0.9)
	for woman: Npc in woman_points.women:
		if woman.npc_name == Npc.NpcName.Louise: continue
		woman.replace_with_agent()
	woman_points.clean_delete_references()
	francois.is_fighting = true
	louise.is_fighting = true
	game_manager.cannon.move_to_second_path()
	game_manager.cannon.enabled = true
	player.can_die = true
	await wait_until(is_barricade_damaged)

	############ FOR DEBUG#########################
	add_on_process(add_worker_on_cannon)

	battle_director.go_next_covers_activation() ####################################### Barricade 2 endommagée
	await wait_until(is_barricade_very_damaged)
	battle_director.go_next_covers_activation() ####################################### Barricade 2 très endommagée
	await wait_signal(game_manager.second_barricade.just_destroyed)

	############ FOR DEBUG#########################
	clean_process()

	game_manager.cannon.enabled = false
	await wait(10.0)
	battle_director.go_next_covers_activation() ####################################### 10s après barricade 2 détruite


func is_barricade_damaged() -> bool:
	return game_manager.curr_barricade.state >= 1


func is_barricade_very_damaged() -> bool:
	return game_manager.curr_barricade.state >= 2
