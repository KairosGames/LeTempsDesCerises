extends Node

var player : Node3D
var allies : Array[Node3D]
var enemies : Array[Node3D]
var text : Array[String] = ["Mort à la canaille !", "Phillipe !", "Saignez-les !"]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	barks_loop()

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

func barks_loop():
	print("bark")
	await get_tree().create_timer(5).timeout
	enemies.pick_random().bark(text.pick_random())
	barks_loop()
