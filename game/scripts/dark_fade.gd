class_name DarkFade extends ColorRect

var twn: Tween


func fade(is_in: bool, time: float = 0.4) -> void:
	if twn: twn.kill()
	twn = create_tween()
	var ratio = 1.0 - color.a if is_in else color.a
	var targ: float = 1.0 if is_in else 0.0
	twn.tween_property(self, "color:a", targ, time * ratio)
	await twn.finished
