class_name FlashScreenEffect extends ColorRect

var twn: Tween

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("choice_surrender"):
		play_flash_effect()

func play_flash_effect() -> void:
	color.a = 0.5
	await get_tree().create_timer(0.025).timeout
	if twn: twn.kill()
	twn = create_tween()
	twn.tween_property(self, "color:a", 0.0, 0.1)
