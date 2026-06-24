extends Node

var player : Node3D
var allies : Array[Node3D]
var enemies : Array[Node3D]
var cannon_workers : Array[Node3D]
var narrators : Array[Node3D]
var barricade : Node3D
var is_coward = false
var coward_distance : int = 600
var game_manager : GameManager
var line_count : int = 0
var allow_barks : bool = true
var allow_subtitles : bool = true
var move_gate : int = 0
var reload_gate : bool = true
var bypass_line : bool = false
var is_looping : bool = true
var ready_narrators : Dictionary = {}
var relevant_narrators : int = 0

func on_game_manager_ready(gm: GameManager) -> void:
	game_manager = gm
	if not game_manager or not game_manager.use_narrative:
		return
	while not Wwise.is_initialized(): await get_tree().process_frame
	await get_tree().process_frame
	await _wait_for_narrators_ready()
	_connect_game_manager_signals()
	game_manager.is_wwise_ready = true
	loop()

func _connect_game_manager_signals() -> void:
	if not game_manager.all_states[0].first_fire_from_barricade.is_connected(pan):
			game_manager.all_states[0].first_fire_from_barricade.connect(pan)
	if not game_manager.clicked_pause.is_connected(pause):
		game_manager.clicked_pause.connect(pause)
	if not game_manager.voice_line_called.is_connected(new_line):
		game_manager.voice_line_called.connect(new_line)
	if game_manager.all_states.size() > 3:
		if not game_manager.all_states[3].choose_surrender.is_connected(surrender):
			game_manager.all_states[3].choose_surrender.connect(surrender)
		if not game_manager.all_states[3].choose_fight_to_death.is_connected(fight):
			game_manager.all_states[3].choose_fight_to_death.connect(fight)
		game_manager.all_states[3].ending_music_choice_scene.connect(stop_barks)
		game_manager.all_states[3].game_ended.connect(end)
	if game_manager.all_states.size() > 1:
		if not game_manager.all_states[1].player_tried_to_exit.is_connected(player_far):
			game_manager.all_states[1].player_tried_to_exit.connect(player_far)
	game_manager.all_states[2].player_passed_behind_second_barricade.connect(stop_barks)
	game_manager.cannon.is_ready_to_shoot_in_cinematic.connect(first_cannon)

func end():
	Wwise.post_event("End", self)

func new_line(step : int):
	relevant_narrators = 0
	if step == 30 :
		bypass_line = true
		return
	else :
		bypass_line = false
	line_count = 0
	Wwise.set_state("narrative_step", String("_" + str(step)))
	for i in narrators:
		if is_instance_valid(i) and is_narrator_ready(i):
			i.voiceline()

func line_ended(_npc_name : String):
	if bypass_line:
		game_manager.curr_state.voice_line_finished.emit()
		return
	line_count += 1
	if line_count == narrators.size():
		game_manager.curr_state.voice_line_finished.emit()

func flip_barks_system():
	if allow_barks:
		for i in allies:
			i.delay = randf_range(0.5, 5)
			i.trigg_bark()
		for i in enemies:
			i.delay = randf_range(0.5, 5)
			i.trigg_bark()

func pan():
	Wwise.post_event("Npc_Shoot", self)

func register(target : Node3D, type : String):
	if type == "ally":
		allies.append(target)
	elif type == "enemy":
		enemies.append(target)

func remove(target : Node3D):
	if allies.has(target):
		allies.erase(target)
		if !allies.is_empty():
			find_random(allies).post_event("Ally_Death", 1.5)
	elif enemies.has(target):
		enemies.erase(target)

func find_closest(type : Array, target : Node3D) -> Node3D :
	var closest : Node3D = null
	for agent : Node3D in type:
		if closest == null:
			closest = agent
		elif agent.global_position.distance_squared_to(target.global_position) < closest.global_position.distance_squared_to(player.global_position) and !agent.is_barking:
			closest = agent
	return closest

func find_farthest(type : Array) -> Node3D :
	var farthest : Node3D = null
	for i : Node3D in type:
		if farthest == null:
			farthest = i
		elif i.global_position.distance_squared_to(player.global_position) > farthest.global_position.distance_squared_to(player.global_position):
			farthest = i
	return farthest

func find_random(type : Array) -> Node3D :
	var random : Array = type
	random.shuffle()
	for i in random:
		if !i.is_barking:
			return i
	return find_closest(type, player)

func cannon_fire():
	if !allies.is_empty():
		for ally in allies:
			ally.post_event("Cannon_Fire", randf_range(1, 5))
		#find_closest(allies, barricade).post_event("Cannon_Fire", 1)
		#find_random(allies).post_event("Cannon_Fire", 3)
	if !enemies.is_empty():
		find_closest(enemies, player).post_event("Cannon_Fire", 1)
		find_random(enemies).post_event("Cannon_Fire", randf_range(2, 5))
		find_random(enemies).post_event("Cannon_Fire", randf_range(2, 5))

func player_far():
	if is_coward: return
	if !allies.is_empty():
		is_coward = true
		find_closest(allies, player).post_event("Player_Far", 0)
		await get_tree().create_timer(3).timeout
		is_coward = false

func surrender():
	Wwise.set_state("narrative_step", "_30")
	for npc in narrators:
		if npc.npc_name == "Francois":
			npc.voiceline()


func fight():
	Wwise.set_state("narrative_step", "_30")
	for npc in narrators:
		if npc.npc_name == "Louise":
			npc.voiceline()
	await get_tree().create_timer(3.5).timeout
	line_ended("Louise")

func enemy_killed(_target: Node3D):
	await get_tree().create_timer(1.5).timeout
	if !allies.is_empty():
			var closest = find_closest(allies, player)
			closest.post_event("Player_Kill", 0.5)
			#find_farthest(allies).post_event("Player_Kill", randf_range(1, 2))

func localize(language : String):
	print("change language")
	Wwise.set_current_language(language)

func unload_npc(remove_name : String):
	for npc in narrators:
		if npc.npc_name == remove_name:
			narrators.erase(npc)
			ready_narrators.erase(npc)
	Wwise.unload_bank(remove_name)

func on_move_progress(progress: float):
	progress = progress / 0.25
	if  roundf(progress) != move_gate and !cannon_workers.is_empty() :
		move_gate = roundf(progress)
		play_secrure_random_ak_post_event_on_array(cannon_workers, "Cannon_Advance", 0.0)
		play_secure_ak_post_event(find_farthest(allies), "Cannon_Advance", 2.0)
		#find_closest(enemies, player).post_event("Cannon_Advance", 0)
		#find_closest(allies, player).post_event("Cannon_Advance", 1)

func on_reload_progress(progress):
	if progress >= 0.95 and not reload_gate:
		print("pan pan le cannon")
		reload_gate = true
		play_secrure_random_ak_post_event_on_array(cannon_workers, "Cannon_Incoming", 1.0)
		var ally_group: Array[Node] = get_tree().get_nodes_in_group("ak_ally")
		if ally_group.size() <= 0: return
		if barricade and is_instance_valid(barricade):
			play_secure_ak_post_event(find_closest(ally_group, barricade), "Cannon_Incoming", 1.0)
		play_secure_ak_post_event(find_random(ally_group),"Cannon_Incoming", 2)

func first_cannon():
	if !cannon_workers.is_empty():
		find_closest(cannon_workers, player).post_event("Cannon_Incoming", 1)
	reload_gate = false

func pause(new_pause : bool):
	if new_pause:
		Wwise.post_event("Pause", self)
	elif !new_pause:
		Wwise.post_event("Resume", self)


func loop():
	if !is_looping : return
	if !allies.is_empty():
		find_random(allies).post_event("Barricade_State", randf_range(0, 5))
	if !enemies.is_empty():
		find_random(enemies).post_event("Barricade_State", randf_range(0, 5))
	await get_tree().create_timer(5).timeout
	loop()

func stop_barks():
	is_looping = false

func register_narrator(narrator: Node3D) -> void:
	if not narrators.has(narrator):
		narrators.append(narrator)
		ready_narrators[narrator] = false

func mark_narrator_ready(narrator: Node3D) -> void:
	if narrators.has(narrator):
		ready_narrators[narrator] = true

func is_narrator_ready(narrator: Node3D) -> bool:
	return ready_narrators.get(narrator, false)

func _wait_for_narrators_ready() -> void:
	while true:
		var has_pending_narrators := false
		for narrator in narrators:
			if is_instance_valid(narrator) and not is_narrator_ready(narrator):
				has_pending_narrators = true
				break
		if not has_pending_narrators:
			return
		await get_tree().process_frame

#### SECURE FUNCTIONS

func play_secure_ak_post_event(ak_node: Node3D, event: String, delay: float) -> void:
	if not ak_node or not is_instance_valid(ak_node): return
	ak_node.post_event(event, delay)

func play_secrure_random_ak_post_event_on_array(ak_nodes: Array, event: String, delay: float) -> void:
	if ak_nodes.size() > 0:
		var rnd: int = randi_range(0, ak_nodes.size() - 1)
		if ak_nodes[rnd] and is_instance_valid(ak_nodes[rnd]):
			play_secure_ak_post_event(ak_nodes[rnd], event, delay)
