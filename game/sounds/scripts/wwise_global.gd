extends Node

var player : Node3D
var allies : Array[Node3D]
var enemies : Array[Node3D]
var cannon_workers : Array[Node3D]
var narrators : Array[Node3D]
var allowed_switch : Array[String] = ["Zone1", "BarricadeBien"]
var barricade : Node3D
var is_coward = false
var coward_distance : int = 600
var game_manager : GameManager
var line_count : int = 0 
var allow_barks : bool = true
var move_gate : int = 0
var reload_gate : bool = false
var bypass_line : bool = false

func _ready() -> void:
	await get_tree().create_timer(1).timeout
	game_manager = GameManager.instance
	if game_manager and game_manager.use_narrative:
		game_manager.clicked_pause.connect(pause)
		game_manager.voice_line_called.connect(new_line)
		game_manager.all_states.get(3).choose_surrender.connect(surrender)
		game_manager.all_states.get(3).choose_fight_to_death.connect(fight)
		await get_tree().create_timer(0.5).timeout
		new_line(0)
	if game_manager: game_manager.all_states[1].player_tried_to_exit.connect(player_far)

func _process(_delta: float) -> void:
	if barricade != null and barricade.global_position.distance_squared_to(player.global_position) > coward_distance and is_coward == false:
		pass

func new_line(step : int):
	if step == 30 :
		bypass_line == true
		return
	else :
		bypass_line = false
	print("step is ", step)
	line_count = 0
	Wwise.set_state("narrative_step", String("_" + str(step)))
	for i in narrators:
		if is_instance_valid(i):
			i.voiceline()

func line_ended(_npc_name : String):
	if bypass_line:
		game_manager.curr_state.voice_line_finished.emit()
		return
	line_count += 1
	#print(npc_name, " : ", line_count, " / ", narrators.size())
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
			ally.post_event("Cannon_Fire", randf_range(1, 3))
		#find_closest(allies, barricade).post_event("Cannon_Fire", 1)
		#find_random(allies).post_event("Cannon_Fire", 3)
	if !enemies.is_empty():
		find_closest(enemies, player).post_event("Cannon_Fire", 1)
		find_random(enemies).post_event("Cannon_Fire", randf_range(2, 5))
		find_random(enemies).post_event("Cannon_Fire", randf_range(2, 5))
		print(barricade.life, " life")
	match barricade.life :
		3:
			Wwise.set_state("barricade_state", "intact")
		2:
			Wwise.set_state("barricade_state", "intact")
		1:
			Wwise.set_state("barricade_state", "low")
		0:
			Wwise.set_state("barricade_state", "broken")

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

func enemy_killed(_target: Node3D):
	await get_tree().create_timer(1.5).timeout
	if !allies.is_empty():
			var closest = find_closest(allies, player)
			closest.post_event("Player_Kill", 0.5)
			#find_farthest(allies).post_event("Player_Kill", randf_range(1, 2))

func localize():
	print("change language")
	Wwise.set_current_language("English(US)")

func unload_npc(remove_name : String):
	for npc in narrators:
		if npc.npc_name == remove_name:
			narrators.erase(npc)
	Wwise.unload_bank(remove_name)

func on_move_progress(progress : float):
	progress = progress / 0.25
	print(roundi(progress))
	if  roundf(progress) != move_gate and !cannon_workers.is_empty() :
		print("bark cannon advance")
		move_gate = roundf(progress)
		cannon_workers.pick_random().post_event("Cannon_Advance", 0)
		#find_closest(enemies, player).post_event("Cannon_Advance", 0)
		#find_closest(allies, player).post_event("Cannon_Advance", 1)
		find_farthest(allies).post_event("Cannon_Advance", 2)

func on_reload_progress(progress):
	if progress >= 0.9:
		reload_gate = true
		cannon_workers.pick_random().post_event("Cannon_Incoming", 0)
		find_closest(allies, barricade).post_event("Cannon_Incoming", 1)
		find_random(allies).post_event("Cannon_Incoming", 2)

func pause(new_pause : bool):
	if new_pause:
		Wwise.post_event("Pause", player)
	elif !new_pause:
		Wwise.post_event("Resume", player)
