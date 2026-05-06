extends Node3D

@export var shoot_event : AkEvent3D

# Called when the node enters the scene tree for the first time.
func moving():
	pass

func shoot():
	shoot_event.post_event()
