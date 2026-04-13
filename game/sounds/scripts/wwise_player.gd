extends Node3D

var is_walking := false

@export var player : Player
@export var shoot : AkEvent3D
@export var steps : AkEvent3D
@export var bullet_prefab : PackedScene

func _ready() -> void:
	#Input.start_joy_vibration(0, 1.0, 1.0, 1.0)
	if Input.get_connected_joypads().is_empty() : return
	for i in Input.get_connected_joypads():
		print("id", i)
	Wwise.add_output("Motion", (0))

func _unhandled_input(_event: InputEvent) -> void:

	if Input.is_action_just_pressed("shoot"):
		Wwise.set_state("player_aim", str(player.is_aiming))
		shoot.post_event()
		var target : Node3D = player.weapon_ray_cast.get_collider()
		var hit_position : Vector3 = player.weapon_ray_cast.get_collision_point()
		var hit = bullet_prefab.instantiate()
		hit.position = hit_position
		var delay : float = self.global_position.distance_to(hit_position)/375
		await get_tree().create_timer(delay).timeout
		call_deferred("add_child", hit)
		if target == null : return
		for i in target.get_children():
			if i.has_meta("Surface"):
				print(i.get_meta("Surface"))
				#Wwise.set_switch("bullet_material",i.get_meta("Surface"), self)
	
	if Input.is_action_just_pressed("crouch"):
		if !player.is_crouched:
			Wwise.set_state("player_stance", "crouch")
		else:
			Wwise.set_state("player_stance", "up")

func _process(delta: float) -> void:
	if player.is_on_floor() and player.velocity.x + player.velocity.z != 0 and !is_walking:
		steps.post_event()
		is_walking = true
	elif is_walking and player.velocity.x + player.velocity.z == 0 or !player.is_on_floor():
		steps.stop_event()
		is_walking = false
