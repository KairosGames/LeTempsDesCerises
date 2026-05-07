class_name DeathCamera extends Camera3D

@onready var player: Player = get_parent()

var is_active: bool
var fall_twn: Tween
var fall_rot_twn: Tween

var first_pos: Vector3
var first_rot: Vector3


func _ready() -> void:
	player.on_death.connect(handle_death)
	first_pos = player.global_position
	first_rot = player.global_rotation


func handle_death() -> void:
	var p_cam: Camera3D = player.player_camera
	fov = p_cam.fov
	global_position = p_cam.global_position
	global_rotation = p_cam.global_rotation
	current = true
	is_active = true
	play_fall_effect()


func play_fall_effect() -> void:
	fall_twn = create_tween()
	fall_rot_twn = create_tween()
	var ground_y: float = player.global_position.y
	fall_twn.tween_property(self, "global_position:y", ground_y + 0.3, 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	fall_twn.tween_property(self, "global_position:y", ground_y + 0.1, 0.5).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	var z_rot: float = 90.0 if randi() % 2 else -90.0
	var fall_rot: Vector3 = Vector3(0.0, -z_rot, global_rotation_degrees.z + z_rot)
	fall_rot_twn.tween_property(self, "global_rotation_degrees", fall_rot, 0.3)
	await get_tree().create_timer(2.0).timeout
	
	var communard: Array = get_tree().get_nodes_in_group("Communard")
	
	
	var rand: float = 1.0 if randi() % 2 else -1.0
	var pos: Vector3 = Vector3 (first_pos.x + (6.0 * rand), 0.0, 0.0)
	var rot: Vector3 = Vector3 (0.0, -90.0 * rand, 0.0)
	is_active = false
	player.revive(pos, rot)


func get_free_communard() -> Agent:
	var communards: Array = get_tree().get_nodes_in_group("Communard")
	var nearer_communard: Agent = null
	var max
	#for communard in communards:
	return
