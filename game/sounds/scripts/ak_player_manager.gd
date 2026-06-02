extends Node3D

var is_walking := false
var is_crouched := false
var is_prone := false
var controller_id
var first_reload : bool = true

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
	WwiseGlobal.player = self
	init_motion()
	player.die_called.connect(death_event)
	player.enemy_shot.connect(WwiseGlobal.enemy_killed)
	player.shot.connect(shoot_event)
	player.tried_shoot_no_reload.connect(no_ammo)

func _unhandled_input(_event: InputEvent) -> void:
	
	if Input.is_action_just_pressed("aim"):
		Wwise.set_state("player_aim", str(!player.is_aiming))

	if Input.is_action_just_pressed("crouch"):
		match player.curr_posture:
			player.Posture.STAND:
				crouch.post_event()
			player.Posture.CROUCH:
				up.post_event()
			player.Posture.PRONE:
				crouch.post_event()

	if Input.is_action_just_pressed("prone"):
		match player.curr_posture:
			player.Posture.STAND:
				crouch.post_event()
				await get_tree().create_timer(0.25).timeout
				prone.post_event()
			player.Posture.CROUCH:
				prone.post_event()
			player.Posture.PRONE:
				crouch.post_event()
				await get_tree().create_timer(0.25).timeout
				up.post_event()

func _process(_delta: float) -> void:
	
	if player.is_running:
		Wwise.set_state("player_stance", "sprint")
	elif player.curr_posture == player.Posture.STAND:
		Wwise.set_state("player_stance", "stand")

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

func shoot_event():
	if !player.can_shoot() : return
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

func no_ammo():
	pass

func on_reload():
	reload.post_event()

func death_event():
	self.reparent(player.player_camera)
	death.post_event()


func _on_reload_ui_try_failed() -> void:
	pass # Replace with function body.


func _on_reload_ui_try_succeeded() -> void:
	reload.post_event()


func _on_reload_ui_entered_reload() -> void:
	if first_reload:
		reload.post_event()
		!first_reload

func init_motion():
	if Input.get_connected_joypads().is_empty() : return
	for i in Input.get_connected_joypads():
		Wwise.add_output("Motion", (i))
