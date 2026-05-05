class_name DeathCamera extends Camera3D

var player: Player
var is_active: bool

var fall_twn: Tween
var fall_rot_twn: Tween

func _ready() -> void:
	player = get_parent() as Player
	player.on_death.connect(handle_death)


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
	fall_twn.tween_property(self, "global_position:y", 0.3, 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	fall_twn.tween_property(self, "global_position:y", 0.1, 0.5).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	var z_rot: float = 90.0 if randi() % 2 else -90.0
	var fall_rot: Vector3 = Vector3(0.0, -z_rot, global_rotation_degrees.z + z_rot)
	fall_rot_twn.tween_property(self, "global_rotation_degrees", fall_rot, 0.3)
