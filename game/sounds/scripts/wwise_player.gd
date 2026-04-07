extends Node3D

var aiming := false

@export var player : CharacterBody3D
@export var shoot : AkEvent3D

# Called when the node enters the scene tree for the first time.
func _unhandled_input(_event: InputEvent) -> void:

	if Input.is_action_just_pressed("shoot"):
		Wwise.set_state("player_aim", str(player.is_aiming))
		shoot.post_event()
