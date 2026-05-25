extends Node

var player : Node3D
var allies : Array[Node3D]
var enemies : Array[Node3D]
var allowed_switch : Array[String] = ["Zone1", "BarricadeBien"]
var barricade : Node3D
var is_coward = false
var coward_distance : int = 600

# Called when the node enters the scene tree for the first time.

func _process(_delta: float) -> void:
	if barricade.global_position.distance_squared_to(player.global_position) > coward_distance and is_coward == false:
		coward()

func register(target : Node3D, type : String):
	if type == "ally":
		allies.append(target)
	else:
		enemies.append(target)

func remove(target : Node3D):
	if allies.has(target):
		allies.erase(target)
		if !allies.is_empty():
			allies.pick_random().ally_dead.post_event()
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

func select_random(type : Array) -> Node3D :
	for i in type:
		if !i.is_barking:
			return i
	return find_closest(type)

func cannon_checkpoint():
	pass
	("le canon arrive")

func cannon_ready():
	pass
	print("ils vont tirer")

func cannon_shoot():
	if !allies.is_empty():
		select_random(allies).bark.post_event()

func coward():
	if !allies.is_empty():
		is_coward = true
		find_closest(allies).coward.post_event()
		print("coward")
		await get_tree().create_timer(10).timeout
		is_coward = false

func retreat():
	Wwise.set_state("fight_state", "retreat")

func fight():
	Wwise.set_state("fight_state", "fight")

func enemy_killed():
	await get_tree().create_timer(1.5).timeout
	if !allies.is_empty():
			var closest = find_closest(allies)
			closest.enemy_dead.post_event()
