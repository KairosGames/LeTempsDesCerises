class_name FlashScreenEffect extends ColorRect

var twn: Tween

func play_flash_effect() -> void:
	color.a = 0.5
	await get_tree().create_timer(0.025).timeout
	if twn: twn.kill()
	twn = create_tween()
	twn.tween_property(self, "color:a", 0.0, 0.1)
