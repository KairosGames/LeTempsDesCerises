class_name GameState03 extends GameState

signal army_foot_steps
signal choose_surrender
signal choose_fight_to_death
signal game_ended

@onready var louise: Npc = %Louise
@onready var discussion_point: CustomMarker = %DiscussionPoint
@onready var francois_moved_pos: CustomMarker = %FrancoisMovedPos
@onready var louise_pos: CustomMarker = %Louise02
@onready var francois_cover: CustomMarker = %FrancoisCover
@onready var louise_cover: CustomMarker = %LouiseCover
@onready var player_cover: CustomMarker = %PlayerCover
@onready var versaillais_points: VersaillaisPoints = %VersaillaisPoints
@onready var execution_point: CustomMarker = %ExecutionPoint
@onready var francois_death: CustomMarker = $FrancoisDeath

var is_surrending: bool = false
var is_time_to_die: bool = false


func enter() -> void:
	curr_step = 0
	steps = [
		Step.new(wait_no_more_allies, player_go_to_cover, launch_dialogue),
		Step.new(launch_player_choice, do_nothing, do_nothing),
		null,
	]
	run_steps()
	if game_manager.use_debug: set_game_for_debug()


func exit() -> void:
	pass


func set_game_for_debug() -> void:
	for i: int in range(13): battle_director.go_next_covers_activation()
	voice_line_index = 26
	francois.global_position = discussion_point.global_position
	francois.global_rotation = francois_moved_pos.global_rotation
	francois.is_fighting = true
	louise.global_position = louise_pos.global_position
	louise.global_rotation = louise_pos.global_rotation
	louise.visible = true
	louise.is_fighting = true
	player.global_position = francois_moved_pos.global_position
	player.blink_effect.set_eyes_to_step(BlinkEffect.EyesStep.OPEN)
	player.give_or_drop_weapon(true)
	player.is_weapon_loaded = true
	ui_manager.hard_set_letter_box(false)
	for i: int in range(0,6): game_manager.handle_cannon_shoot()
	game_manager.cannon._is_first_shoot = false
	ui_manager.set_objective(true, null, "Defend the barricade alongside your comrades")


func wait_no_more_allies() -> void:
	louise.is_fighting = false
	francois.is_fighting = false
	louise.launch_movement_to_nav_point(louise_cover, 4.0, true)
	francois.launch_movement_to_nav_point(francois_cover, 4.0, true)
	await wait_until(are_louise_and_francois_on_covers)
	
	############# FOR DEBUG
	add_on_process(kill_agents.bind(false, true))
	
	await wait_until(is_there_one_ally)
	await wait_until(is_player_alive)
	player.can_die = false
	
	############# FOR DEBUG
	add_on_process(kill_agents.bind(false, true))
	await wait_until(is_there_no_allies)
	
	############# FOR DEBUG


func are_louise_and_francois_on_covers() -> bool:
	return louise.is_all_nav_finished and francois.is_all_nav_finished


func is_there_one_ally() -> bool:
	var list: Array[Node] = get_tree().get_nodes_in_group("Communard").filter(func(o): return o is not Player)
	return list.size() <= 1


func is_there_no_allies() -> bool:
	var list: Array[Node] = get_tree().get_nodes_in_group("Communard").filter(func(o): return o is not Player)
	return list.size() <= 0


func player_go_to_cover() -> void:
	player.can_play = false
	ui_manager.set_objective(false)
	await run_to_destination(player_cover)
	louise.is_fighting = false
	louise.enter_in_crouch_anim()
	francois.is_fighting = false
	francois.enter_in_crouch_anim()
	
	print("LES DEUX CROUCH")
	
	var target: Vector3 = player_cover.global_position + player_cover.basis.z
	var time_ratio: float = get_yaw_diff_ratio(target)
	await tween_rotate_player_to_pos(versaillais_points.dialogue_points[0].global_position, 1.0 * time_ratio)
	await player.prone_to_stand(true)
	launch_player_crouch()
	versaillais_points.set_all_versaillais_spwan_pos()
	army_foot_steps.emit()
	versaillais_points.all_versaillais_go_to_dialogue_pos()
	await wait_until(are_all_versaillais_in_pos)


func are_all_versaillais_in_pos() -> bool:
	for versaillais: Npc in versaillais_points.all_versaillais:
		if not versaillais.is_all_nav_finished: return false
	return true


func launch_player_crouch() -> void:
	await wait(0.4)
	player.prone_to_crouch(false, 1.2)


func launch_dialogue() -> void:
	await wait_voice() # "Rendez vous, racailles rouges"
	await francois.rotate_yaw_to_pos_tween(player_cover.global_position, 0.6)
	await wait_voice() # "C'en est fini citoyens, rendons-nous"
	await louise.rotate_yaw_to_pos_tween(player_cover.global_position, 0.6)
	await wait_voice() # "Jamais. Puisqu'il semble que tout cœur qui bat pour la liberté"


func launch_player_choice() -> void:
	await ui_manager.launch_letter_box(false)
	handle_choice_display()
	await wait_until(is_choice_done)
	clean_ui_process()
	ui_manager.choice_tooltip.visible = false
	await ui_manager.launch_letter_box(true)
	var l_targ: Vector3 = louise_cover.global_position + louise_cover.basis.z
	var f_targ: Vector3 = francois_cover.global_position + francois_cover.basis.z
	louise.rotate_yaw_to_pos_tween(l_targ, 0.4)
	await wait(0.2)
	await francois.rotate_yaw_to_pos_tween(f_targ, 0.6)
	await wait(0.5)


func handle_choice_display() -> void:
	was_gpad = player.p_inputs.is_gamepad
	add_on_process(process_choice_display, true)
	ui_manager.choice_tooltip.set_labels(was_gpad)
	ui_manager.choice_tooltip.visible = true


func process_choice_display() -> void:
	if was_gpad == player.p_inputs.is_gamepad: return
	was_gpad = player.p_inputs.is_gamepad
	ui_manager.choice_tooltip.set_labels(was_gpad)


func is_choice_done() -> bool:
	if Input.is_action_just_pressed("choice_surrender"):
		steps[2] = Step.new(launch_execution, do_nothing, do_nothing)
		is_surrending = true
		choose_surrender.emit()
		return true
	if Input.is_action_just_pressed("choice_fight_to_death"):
		steps[2] = Step.new(launch_fight_to_death, do_nothing, do_nothing)
		is_surrending = false
		choose_fight_to_death.emit()
		return true
	return false


func launch_execution() -> void:
	francois.enter_in_idle_anim()
	launch_louise_and_player_surrender()
	await wait_voice() # "Arrêtez, nous nous rendons !"
	await wait(1.0)
	await ui_manager.dark_fade.fade(true, 0.6)
	versaillais_points.set_all_versaillais_final_pos()
	player.global_position = execution_point.global_position
	take_player_move_control(false)
	await tween_rotate_player_to_yaw(execution_point.global_rotation.y, 0.1)
	francois.enter_in_stand_no_weapon()
	francois.global_position = player.global_position + (player.basis.x * 2.0)
	francois.global_rotation.y = player.global_rotation.y
	louise.enter_in_stand_no_weapon()
	louise.global_position = player.global_position - (player.basis.x * 2.0)
	louise.global_rotation.y = player.global_rotation.y
	await wait(1.0)
	await ui_manager.dark_fade.fade(false, 0.6)
	set_player_before_execution()
	ui_manager.launch_letter_box(false)
	await wait(10.0)
	call_voice() ########################### "Soldats en joug !"
	ui_manager.launch_letter_box(true)
	take_player_view_control(true)
	player.can_play = false
	player.can_use_view = false
	clean_process()
	rot_twn = create_tween()
	var view_targ: Vector3 = Vector3(0.0, rad_to_deg(execution_point.global_rotation.y), 0.0)
	await rot_twn.tween_property(player, "aim_target", view_targ, 0.5).finished
	await wait(1.0)
	await wait_voice() # "Armez !"
	await player.blink_effect.move_eyes(BlinkEffect.EyesStep.CLOSED, 0.45, true, 4.0)
	await wait_voice() # " Feu !"
	versaillais_points.versillais_shoot_for_execution()
	await wait(0.1)
	player.die_called.emit()
	await wait(0.1)
	player.died.emit()
	await wait(3.0)
	game_ended.emit()


func launch_louise_and_player_surrender() -> void:
	await wait(0.3)
	louise.enter_in_idle_anim()
	await wait(0.4)
	player.crouch_to_stand(false, false, 1.0)
	player.give_or_drop_weapon(false)


func set_player_before_execution() -> void:
	player.set_is_free(false)
	player.can_play = true
	player.can_use_view = true
	take_player_view_control(false)
	add_on_process(clamp_view.bind(player.aim_target, 50.0, 100.0))


func launch_fight_to_death() -> void:
	louise.enter_in_idle_anim()
	await wait_voice()
	louise.enter_in_aim()
	await wait(0.3)
	versaillais_points.versaillais_kill_louise()
	await wait(0.1)
	louise.die()
	await wait(0.3)
	launch_francois_death()
	await player.crouch_to_stand(false, false, 0.6)
	ui_manager.launch_letter_box(false)
	set_player_for_fight_to_the_death()
	launch_death_timer()
	await wait_until(is_it_time_to_die)
	await wait(0.5)
	versaillais_points.versaillais_kill_player()
	await wait(0.1)
	set_player_to_last_death()
	player.die(true, true)
	await wait(6.0)
	game_ended.emit()


func launch_francois_death() -> void:
	francois.launch_movement_to_nav_point(francois_death, 4.0, true)
	await wait_until(francois.is_on_all_nav_finished)
	await wait(0.3)
	versaillais_points.versaillais_kill_francois()
	await wait(0.1)
	francois.die()


func set_player_for_fight_to_the_death() -> void:
	player.set_is_free(false)
	take_player_view_control(false)
	take_player_move_control(false)
	player.can_play = true
	player.can_use_view = true
	player.can_use_aim = true
	player.can_use_shoot = true
	player.can_quit_aim = true
	player.can_use_reload = true
	add_on_process(clamp_view.bind(player.aim_target, 50.0, 60.0))


func launch_death_timer() -> void:
	await wait(7.0)
	is_time_to_die = true


func is_it_time_to_die() -> bool:
	if is_time_to_die: return true
	if Input.is_action_just_pressed("aim"): return true
	if Input.is_action_just_pressed("shoot"): return true
	if Input.is_action_just_pressed("reload") and not player.is_weapon_loaded: return true
	return false


func set_player_to_last_death() -> void:
	player.set_is_free(false)
	player.can_play = false
	player.can_die = true
	player.is_immortal = false
