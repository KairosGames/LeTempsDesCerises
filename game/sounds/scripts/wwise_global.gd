extends Node

var player : Node3D
var allies : Array[Node3D]
var enemies : Array[Node3D]
var narrators : Array[Node3D]
var allowed_switch : Array[String] = ["Zone1", "BarricadeBien"]
var barricade : Node3D
var is_coward = false
var coward_distance : int = 600
var game_manager : GameManager
var line_count : int = 0 
var allow_barks : bool = true

func _ready() -> void:
	await get_tree().create_timer(1).timeout
	game_manager = GameManager.instance
	if game_manager and game_manager.use_narrative:
		game_manager.curr_state.voice_line_called.connect(new_line)
		await get_tree().create_timer(0.5).timeout
		new_line(0)
	if game_manager: game_manager.all_states[1].player_tried_to_exit.connect(player_far)

func _process(_delta: float) -> void:
	if barricade != null and barricade.global_position.distance_squared_to(player.global_position) > coward_distance and is_coward == false:
		pass

func new_line(step : int):
	line_count = 0
	Wwise.set_state("narrative_step", String("_" + str(step)))
	for i in narrators:
		i.voiceline()

func line_ended():
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

func register(target : Node3D, type : String):
	if type == "ally":
		allies.append(target)
	elif type == "enemy":
		enemies.append(target)

func remove(target : Node3D):
	if allies.has(target):
		allies.erase(target)
		if !allies.is_empty():
			allies.pick_random().post_event("Ally_Death", 1.5)
	elif enemies.has(target):
		enemies.erase(target)

func find_closest(type : Array) -> Node3D : 
	var closest : Node3D = null
	for i : Node3D in type:
		if closest == null:
			closest = i
		elif i.global_position.distance_squared_to(player.global_position) < closest.global_position.distance_squared_to(player.global_position):
			closest = i
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
	return find_closest(type)

func cannon_checkpoint():
	pass
	("le canon arrive")

func cannon_incoming():
	find_random(allies).post_event("Cannon_Incoming", 0)

func cannon_fire():
	if !allies.is_empty():
		find_random(allies).post_event("Cannon_Fire", 1)
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
		find_closest(allies).post_event("Player_Far", 0)
		await get_tree().create_timer(3).timeout
		is_coward = false

func retreat():
	Wwise.set_state("fight_state", "retreat")

func fight():
	Wwise.set_state("fight_state", "fight")

func enemy_killed():
	await get_tree().create_timer(1.5).timeout
	if !allies.is_empty():
			var closest = find_closest(allies)
			closest.post_event("Player_Kill", 0.5)
			find_farthest(allies).post_event("Player_Kill", randf_range(1, 2))

func localize():
	print("change language")
	Wwise.set_current_language("English(US)")

func unload(bank_name : String):
	Wwise.unload_bank(bank_name)
