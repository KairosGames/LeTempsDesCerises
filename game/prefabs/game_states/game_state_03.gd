class_name GameState03 extends GameState

signal army_foot_steps

@onready var louise: Npc = %Louise
@onready var discussion_point: CustomMarker = %DiscussionPoint
@onready var francois_moved_pos: CustomMarker = %FrancoisMovedPos
@onready var louise_pos: CustomMarker = %Louise02
@onready var francois_cover: CustomMarker = %FrancoisCover
@onready var louise_cover: CustomMarker = %LouiseCover
@onready var player_cover: CustomMarker = %PlayerCover
@onready var versaillais_points: VersaillaisPoints = %VersaillaisPoints


func enter() -> void:
	curr_step = 0
	steps = [
		Step.new(wait_no_more_allies, player_go_to_cover, do_nothing),
		Step.new(do_nothing, do_nothing, do_nothing),
	]
	run_steps()
	if game_manager.use_debug: set_player_for_debug()


func exit() -> void:
	pass


func set_player_for_debug() -> void:
	francois.global_position = discussion_point.global_position
	francois.global_rotation = francois_moved_pos.global_rotation
	francois.is_figthing = true
	louise.global_position = louise_pos.global_position
	louise.global_rotation = louise_pos.global_rotation
	louise.visible = true
	louise.is_figthing = true
	player.global_position = francois_moved_pos.global_position
	player.blink_effect.set_eyes_to_step(BlinkEffect.EyesStep.OPEN)
	player.give_or_drop_weapon(true)
	player.is_weapon_loaded = true
	ui_manager.hard_set_letter_box(false)
	for i in range(0,6): game_manager.handle_cannon_shoot()
	game_manager.cannon._is_first_shoot = false


func wait_no_more_allies() -> void:
	louise.is_figthing = false
	francois.is_figthing = false
	louise.launch_movement_to_nav_point(louise_cover, 5.0, true)
	francois.launch_movement_to_nav_point(francois_cover, 5.0, true)
	await wait_until(are_louise_and_francois_on_covers)
	#var pos: Vector3 = versaillais_points.points[0].global_position
	#louise.rotate_yaw_to_pos_tween(pos, 0.5, true)
	#await francois.rotate_yaw_to_pos_tween(pos, 0.5, true)
	
	await wait_until(is_there_one_ally)
	await wait_until(is_player_alive)
	player.can_die = false
	await wait_until(is_there_no_allies)


func are_louise_and_francois_on_covers() -> bool:
	return louise.is_all_nav_finished and francois.is_all_nav_finished


func is_there_one_ally() -> bool:
	return get_tree().get_nodes_in_group("Communard").size() <= 1


func is_there_no_allies() -> bool:
	return get_tree().get_nodes_in_group("Communard").size() <= 0


func player_go_to_cover() -> void:
	player.can_play = false
	await run_to_destination(player_cover)
	louise.is_figthing = false
	louise.enter_in_crouch_anim()
	francois.is_figthing = false
	francois.enter_in_crouch_anim()
	var target: Vector3 = player_cover.global_position + player_cover.basis.z
	var time_ratio: float = get_yaw_diff_ratio(target)
	await tween_rotate_player_to_pos(versaillais_points.dialogue_points[0].global_position, 1.0 * time_ratio)
	
	#await player.prone_to_stand(true)
	await player.crouch_to_stand(true)
	
	versaillais_points.set_all_versaillais_spwan_pos()
	army_foot_steps.emit()
	versaillais_points.all_versaillais_go_to_dialogue_pos()
	
	await wait_until(are_all_versaillais_in_pos)
	#await wait(2.0)
	#launch_player_crouch()
	#await
	
	await wait_voice() # "Rendez vous, racailles rouges"
	await francois.rotate_yaw_to_pos_tween(player_cover.global_position, 0.6)
	await wait_voice() # "C'en est fini citoyens, rendons-nous"
	await louise.rotate_yaw_to_pos_tween(player_cover.global_position, 0.6)
	await wait_voice() # "Jamais. Puisqu'il semble que tout cœur qui bat pour la liberté"


func launch_player_crouch() -> void:
	await wait(1.0)
	player.prone_to_crouch()


func are_all_versaillais_in_pos() -> bool:
	for versaillais: Npc in versaillais_points.all_versaillais:
		if not versaillais.is_all_nav_finished: return false
	return true
