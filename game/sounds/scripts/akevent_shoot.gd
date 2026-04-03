extends AkListener3D

var aiming := false

# Called when the node enters the scene tree for the first time.
func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("aim"):
		if aiming:
			Wwise.set_state("Player_Aim", "False")
			aiming = false
		else:
			Wwise.set_state("Player_Aim", "True")
			aiming = true
	if Input.is_action_just_pressed("shoot"):
		Wwise.post_event("Player_Shoot", self)
