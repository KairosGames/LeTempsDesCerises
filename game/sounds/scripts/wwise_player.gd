extends Node3D

var aiming := false

@export var player : Player
@export var shoot : AkEvent3D

func _ready() -> void:
	#Input.start_joy_vibration(0, 1.0, 1.0, 1.0)
	for i in Input.get_connected_joypads():
		print("id", i)
	Wwise.add_output("Motion", (0))

func _unhandled_input(_event: InputEvent) -> void:

	if Input.is_action_just_pressed("shoot"):
		Wwise.set_state("player_aim", str(player.is_aiming))
		shoot.post_event()
		var target : Node3D = player.weapon_ray_cast.get_collider()
		return
		for i in target.get_children():
			if i.has_meta("Surface"):
				print(i.get_meta("Surface"))
				Wwise.set_switch("bullet_material",i.get_meta("Surface"), self)
