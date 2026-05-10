extends Node3D

var is_walking := false
var is_crouched := false
var is_prone := false
var controller_id

@export_category("AkEvents")
@export var player : Player
@export var shoot : AkEvent3D
@export var steps : AkEvent3D
@export var reload : AkEvent3D
@export var death : AkEvent3D

@export_category("Stances")
@export var up : AkEvent3D
@export var crouch : AkEvent3D
@export var prone : AkEvent3D
@export var sprint : AkEvent3D

@export_category("Prefabs")
@export var bullet_prefab : PackedScene

func _ready() -> void:
	#Input.start_joy_vibration(0, 1.0, 1.0, 1.0)
	if Input.get_connected_joypads().is_empty() : return
	for i in Input.get_connected_joypads():
		Wwise.add_output("Motion", (i))

	#player.reload_ui.reloaded.connect(on_reload())
	player.on_death.connect(death_event)

func _unhandled_input(_event: InputEvent) -> void:

	if Input.is_action_just_pressed("shoot"):
		if !player.can_use_shoot() : return
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
			if i.has_meta("Surface") and i.get_class() == "MeshInstance3D":
				#print(i.get_meta("Surface"))
				Wwise.set_switch("bullet_material",i.get_meta("Surface"), self)
			#elif i.get_class() == "MeshInstance3D":
				#print("Orlane tu as oublié un mat !")

func _process(_delta: float) -> void:
	
	if player.is_running:
		Wwise.set_state("player_stance", "sprint")
	elif player.curr_posture == player.Posture.STAND:
		Wwise.set_state("player_stance", "stand")

	if player.is_changing_state:
			match player.curr_posture:
				player.Posture.STAND:
					up.post_event()
				player.Posture.CROUCH:
					crouch.post_event()
				player.Posture.PRONE:
					prone.post_event()
	
	if player.local_velocity.length() == 0:
		Wwise.set_rtpc_value("Player_Velocity", 1, null)
	else:
		Wwise.set_rtpc_value("Player_Velocity", remap(player.local_velocity.length(), 0, player.get_used_speed(),0 , 1), null)

	if player.is_on_floor() and player.velocity.x + player.velocity.z != float(0) and !is_walking:
		steps.post_event()
		is_walking = true
	elif is_walking and player.velocity.x + player.velocity.z == 0 or !player.is_on_floor():
		steps.stop_event()
		is_walking = false

func on_reload():
	reload.post_event()

func death_event():
	self.reparent(player.player_camera)
	print("mort")
	death.post_event()


func _on_reload_ui_try_failed() -> void:
	pass # Replace with function body.


func _on_reload_ui_try_succeeded() -> void:
	reload.post_event()


func _on_reload_ui_entered_reload() -> void:
	reload.post_event()


func _on_player_on_death() -> void:
	pass # Replace with function body.
