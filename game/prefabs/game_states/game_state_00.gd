class_name GameState00 extends GameState

signal first_fire_from_barricade
signal fire_kill_georges

@onready var georges_rdv: CustomMarker = %GeorgesRDV
@onready var georges: Npc = %Georges
@onready var first_chassepot: Node3D = %FirstChassepot
@onready var barricade_point: CustomMarker = %BarricadePoint
@onready var jules: Npc = %Jules
@onready var versaillais_coming_point: CustomMarker = $VersaillaisComingPoint
@onready var objective_point_barricade: CustomMarker = %ObjectivePointBarricade
@onready var second_barricade_npc: Npc = %SecondBarricadeNPC

var recorded_pos: Vector3


func enter() -> void:
	curr_step = 0
	steps = [
		Step.new(set_game_for_onboarding, get_up, do_nothing),
		Step.new(go_for_georges, wait_voice, take_weapon), # "Les lignards sont pas loin"
		Step.new(wait_voice, wait_player_crouch, do_nothing), #"Quand t'es derrière un mur"
		Step.new(wait_voice, wait_player_prone, do_nothing), #Si ta couverture est trop basse"
		Step.new(wait_voice, wait_player_stand, do_nothing), #"Bon relève toi"
		Step.new(wait_voice, wait_player_aim, free_changing_posture), #"Tiens essaye de viser"
		Step.new(open_player_view, wait_player_shoot, free_player_view),
		Step.new(wait_voice, wait_player_enter_reload, wait_voice), # "Ah mais il est vide celui là" / # "Terminé te voilà enfin près pour expédier du plomb"
		Step.new(enter_fight_begin, georges_death, free_player)
	]
	if game_manager.use_debug and not set_debug_applied: set_game_for_debug()
	if game_manager.use_short_time: set_short_timers()
	run_steps()


func exit() -> void:
	pass


func set_game_for_debug() -> void:
	player.blink_effect.set_eyes_to_step(BlinkEffect.EyesStep.OPEN)


func set_short_timers() -> void:
	pass


func set_game_for_onboarding() -> void:
	player.blink_effect.set_eyes_to_step(BlinkEffect.EyesStep.CLOSED)
	player.blink_effect.set_blink_enable(true)
	ui_manager.hard_set_letter_box(true)
	var spawn: CustomMarker = game_manager.player_spawner
	player.initiate(spawn.global_position, spawn.global_rotation, false, false, Player.Posture.PRONE)
	player.set_is_free(false)
	player.aim_target.x = -70.0
	player.can_die = false
	set_debug_applied = true
	await wait_until(is_wwise_ready)


func is_wwise_ready() -> bool:
	return game_manager.is_wwise_ready


func get_up() -> void:
	if not game_manager.use_debug:
		await wait_voice() # "Hé Hé ! Réveille toi !"
		await wait(1.0)
		await player.blink_effect.open_eyes_from_sleep()
		await wait(1.5)
	var twn: Tween = create_tween()
	twn.tween_property(player, "aim_target:x", 0.0, 0.7)
	player.play_cam_landing_effect(-0.2, 30.0, 1.0)
	player.prone_to_crouch(false, 1.0)
	await wait(1.1)
	player.play_cam_landing_effect(-0.2, 5.0, 0.5)
	player.crouch_to_stand(false, 0.5)
	await wait(1.1)
	take_player_view_control(true)
	await tween_rotate_player_to_yaw(deg_to_rad(player.aim_target.y) - PI/6.0, 0.6)
	await wait(2.0)
	await tween_rotate_player_to_yaw(deg_to_rad(player.aim_target.y) + PI/6.0, 0.4)
	take_player_view_control(false)
	set_debug_applied = true


func go_for_georges() -> void:
	take_player_move_control(true)
	take_player_view_control(true)
	set_player_move(Vector2(0.0, 0.5))
	add_on_process(rotate_yaw_player_to_pos.bind(georges_rdv.global_position, PI/10.0, delta_t))
	await wait(3.0)
	clean_process()
	await wait_until(func(): return player.global_position.distance_squared_to(georges_rdv.global_position) <= 0.1)
	take_player_move_control(false)
	add_on_process(rotate_yaw_player_to_pos.bind(georges.global_position, PI, delta_t))
	await wait(0.25)
	clean_process()
	take_player_view_control(false)


func take_weapon() -> void:
	take_player_view_control(true)
	add_on_process(rotate_player_to_yaw.bind(georges_rdv.rotation.y, PI/1.5, delta_t))
	await wait(0.5)
	Wwise.set_state("Music_State", "Phase1") ############# MUSIC
	clean_process()
	first_chassepot.visible = false
	take_player_view_control(false)
	player.give_or_drop_weapon(true)


func wait_player_crouch() -> void:
	await ui_manager.launch_letter_box(false)
	handle_action_tooltip("crouch")
	await wait_until_or_signal(func(): return Input.is_action_just_pressed("crouch"), player.p_inputs.gpad_crouch_pressed)
	player.crouch_to_stand(true)
	free_tool_tip()


func wait_player_prone() -> void:
	handle_action_tooltip("prone")
	await wait_until_or_signal(func(): return Input.is_action_just_pressed("prone"), player.p_inputs.gpad_ask_prone)
	player.prone_to_crouch(true)
	free_tool_tip()


func wait_player_stand() -> void:
	handle_action_tooltip("stand")
	await wait_until_or_signal(func(): return Input.is_action_just_pressed("prone"), player.p_inputs.gpad_ask_prone)
	player.prone_to_stand()
	free_tool_tip()


func wait_player_aim() -> void:
	handle_action_tooltip("aim")
	player.can_use_aim = true
	await wait_until(func(): return Input.is_action_just_pressed("aim"))
	free_tool_tip()
	player.can_quit_aim = false
	add_on_process(block_ads_concentration.bind(2.5))
	await wait_voice() #"Quand tu te mets en joue"
	clean_process()
	await wait_voice() #"Ces pétoires sont lourdes"
	await wait(0.5)


func free_changing_posture() -> void:
	player.can_change_posture = true


func open_player_view() -> void:
	handle_action_tooltip("view")
	player.can_use_view = true
	player.can_quit_aim = true
	if player.p_inputs.is_gamepad and not Input.is_action_just_pressed("aim"):
		player.is_aiming = false
		player.switch_aim_state()
	if not player.p_inputs.is_gamepad:
		player.is_aiming = false
		player.switch_aim_state()
	add_on_process(clamp_view.bind(player.aim_target, 30.0, 30.0))
	await wait_voice() #"Allez maintenant essaye de tirer sur ce panneau"
	free_tool_tip()


func wait_player_shoot()-> void:
	handle_action_tooltip("shoot")
	add_on_process(process_shoot_tooltip, true)
	await wait_until(is_player_shooting_target)
	free_tool_tip()
	player.tried_shoot_no_reload.emit()
	if not player.p_inputs.is_gamepad: leave_aim()
	await wait(0.75)
	if player.curr_posture == Player.Posture.PRONE: player.prone_to_stand()


func is_player_shooting_target() -> bool:
	var obj: Object = player.weapon_ray_cast.get_collider()
	if not obj: return false
	return obj is ShootTarget and Input.is_action_just_pressed("shoot")


func process_shoot_tooltip() -> void:
	var obj: Object = player.weapon_ray_cast.get_collider()
	ui_manager.tooltip.display(obj and obj is ShootTarget)


func free_player_view() -> void:
	clean_process()


func wait_player_enter_reload() -> void:
	handle_action_tooltip("reload")
	await wait_until(func(): return Input.is_action_just_pressed("reload"))
	player.enter_reload()
	free_tool_tip()
	player.reload_ui.is_tutorial = true
	player.reload_ui.is_playing_qte = false
	await wait_voice() # "Bien ensuite il faut que tu ouvres la cullase"
	handle_action_tooltip("open_bolt")
	player.reload_ui.is_playing_qte = true
	add_on_process(func(): if Input.is_action_just_pressed("reload"): player.reload_ui.try_qte())
	await wait_until(func(): return player.reload_ui.step == 2)
	free_tool_tip()
	clean_process()
	player.reload_ui.is_playing_qte = false
	await wait_voice() # "Voilà maintenant tu peux y mettre ton pruneau"
	handle_action_tooltip("close_bolt")
	player.reload_ui.is_playing_qte = true
	add_on_process(func(): if Input.is_action_just_pressed("reload"): player.reload_ui.try_qte())
	await wait_until(func(): return player.is_weapon_loaded)
	free_tool_tip()
	player.reload_ui.is_tutorial = false
	clean_process()
	player.can_use_reload = true
	await wait(0.8)
	set_player_before_george_death()


func set_player_before_george_death() -> void:
	ui_manager.launch_letter_box(true)
	player.can_change_posture = false
	player.can_use_view = false
	player.can_use_aim = false
	if player.curr_posture == Player.Posture.CROUCH: player.crouch_to_stand()
	if player.curr_posture == Player.Posture.PRONE: player.prone_to_stand()
	if player.is_aiming:
		player.is_aiming = false
		player.switch_aim_state()
	take_player_view_control(true)
	var targ: Vector3 = georges.global_position + (georges.basis.x * 1.0)
	add_on_process(rotate_yaw_player_to_pos.bind(targ, PI * 1.5, delta_t))
	var twn: Tween = create_tween()
	twn.tween_property(player, "aim_target:x", 10.0, 0.3)


func enter_fight_begin() -> void:
	first_fire_from_barricade.emit()
	await wait(0.3)
	clean_process()
	francois.rotate_yaw_to_pos_tween(versaillais_coming_point.global_position, 0.05)
	add_on_process(rotate_yaw_player_to_pos.bind(barricade_point.global_position, PI * 3.0, delta_t))
	await wait(0.3)
	jules.rotate_yaw_to_pos_tween(versaillais_coming_point.global_position, 0.4)
	await francois.rotate_yaw_to_pos_tween(player.global_position, 0.4)
	jules.is_fighting = true
	second_barricade_npc.is_fighting = true
	await wait_voice() # "Voilà la ligne, ils sont sur nous !"
	take_player_view_control(false)
	clean_process()


func georges_death() -> void:
	battle_director.go_next_covers_activation() ################################## Arrivée ennemis
	await georges.rotate_yaw_to_pos_tween(barricade_point.global_position, 0.2)
	var george_targ: Vector3 = (player.global_position + (player.basis.x * 1.0)) + player.basis.z * 2.0
	georges.enter_in_walk_anim()
	await georges.move_to(george_targ, 4.0)
	georges.enter_in_idle_anim()
	await georges.rotate_yaw_to_pos_tween(player.global_position, 0.3)
	await wait_voice() # "Au mur citoyen !"
	await georges.rotate_yaw_to_pos_tween(barricade_point.global_position, 0.3)
	call_georges_death()
	georges.enter_in_walk_anim()
	await georges.move_to(barricade_point.global_position, 4.0)
	await wait_voice() # "Nooooon ! Ils ont tué Georges !"
	await francois.rotate_yaw_to_pos_tween(versaillais_coming_point.global_position, 0.4)
	francois.is_fighting = true


func call_georges_death() -> void:
	await wait(1.0)
	call_voice() # "Pan ! Argh!"
	await wait(0.1)
	georges.die()


func free_player() -> void:
	ui_manager.launch_letter_box(false)
	player.set_is_free(true)
	recorded_pos = player.global_position
	player.can_use_run = false
	ui_manager.set_objective(true, objective_point_barricade, "Go to the barricade")
	handle_action_tooltip("move")
	await wait_until(has_player_moved_enough)
	free_tool_tip()


func has_player_moved_enough() -> bool:
	return player.global_position.distance_squared_to(recorded_pos) > 9.0
