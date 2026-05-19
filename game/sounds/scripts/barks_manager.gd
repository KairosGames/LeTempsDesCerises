extends Node

var player : Node3D
var allies : Array[Node3D]
var enemies : Array[Node3D]
var allowed_switch : Array[String] = ["Zone1", "BarricadeBien"]

# Called when the node enters the scene tree for the first time.

func register(target : Node3D, type : String):
	if type == "ally":
		allies.append(target)
	else:
		enemies.append(target)

func remove(target : Node3D):
	if allies.has(target):
		allies.erase(target)
	elif enemies.has(target):
		enemies.erase(target)

func closest():
	var closest : Node3D
	for i : Node3D in enemies:
		if closest == null:
			closest = i
		elif i.global_position.distance_to(player.global_position) < closest.global_position.distance_to(player.global_position):
			closest = i
		print(closest.global_position.distance_to(player.global_position))
