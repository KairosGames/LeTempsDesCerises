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
var allow_barks : bool = false

func _ready() -> void:
	await get_tree().create_timer(1).timeout
	game_manager = GameManager.instance
	if game_manager.use_narrative:
		game_manager.curr_state.voice_line_called.connect(new_line)
		new_line(0)
		return
		for i in game_manager.get_children(true):
			if i.name == "NPC":
				for npc in i.get_children():
					var new_npc = preload("res://sounds/prefabs/ak_npc_manager.tscn").instantiate()
					npc.add_child(new_npc)
					new_npc.init()
	else:
		allow_barks = true
		flip_barks_system()

func _process(_delta: float) -> void:
	if barricade != null and barricade.global_position.distance_squared_to(player.global_position) > coward_distance and is_coward == false:
		player_far()

func _unhandled_key_input(event: InputEvent) -> void:
	if Input.is_key_pressed(KEY_ENTER):
		localize()

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
	return
	allow_barks = !allow_barks
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
	else:
		enemies.append(target)

func remove(target : Node3D):
	if allies.has(target):
		allies.erase(target)
		if !allies.is_empty():
			allies.pick_random().post_event("Ally_Death", 1.5)
	elif enemies.has(target):
		enemies.erase(target)

func find_closest(type : Array) -> Node3D : 
	var closest : Node3D
	for i : Node3D in type:
		if closest == null:
			closest = i
		elif i.global_position.distance_squared_to(player.global_position) < closest.global_position.distance_squared_to(player.global_position):
			closest = i
	return closest

func find_random(type : Array) -> Node3D :
	var random : Node3D
	var randomize : Array = type
	randomize.shuffle()
	for i in randomize:
		if !i.is_barking:
			return i
	return find_closest(type)

func select_random(type : Array) -> Node3D :
	for i in type:
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
		select_random(allies).bark.post_event()

func player_far():
	if !allow_barks : return
	if !allies.is_empty():
		is_coward = true
		find_closest(allies).post_event("Player_Far", 0)
		await get_tree().create_timer(10).timeout
		is_coward = false
		for i in allies:
			i.post_event("Player_Far", 0)

func retreat():
	Wwise.set_state("fight_state", "retreat")

func fight():
	Wwise.set_state("fight_state", "fight")

func enemy_killed():
	await get_tree().create_timer(1.5).timeout
	if !allies.is_empty():
			var closest = find_closest(allies)
			closest.post_event("Player_Kill", 1)

func localize():
	print("change language")
	Wwise.set_current_language("English(US)")
