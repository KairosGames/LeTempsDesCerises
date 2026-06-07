class_name Tools


static func dt_lerp(speed: float, delta: float) -> float:
	return 1.0 - exp(-speed * delta)


static func joy_button_to_string(button: JoyButton) -> String:
	match button:
		JOY_BUTTON_A: return "A"
		JOY_BUTTON_B: return "B"
		JOY_BUTTON_X: return "X"
		JOY_BUTTON_Y: return "Y"
		JOY_BUTTON_BACK: return "BACK"
		JOY_BUTTON_GUIDE: return "GUIDE"
		JOY_BUTTON_START: return "START"
		JOY_BUTTON_LEFT_STICK: return "LEFT STICK"
		JOY_BUTTON_RIGHT_STICK: return "RIGHT STICK"
		JOY_BUTTON_LEFT_SHOULDER: return "LB"
		JOY_BUTTON_RIGHT_SHOULDER: return "RB"
		JOY_BUTTON_DPAD_UP: return "D-PAD UP"
		JOY_BUTTON_DPAD_DOWN: return "D-PAD DOWN"
		JOY_BUTTON_DPAD_LEFT: return "D-PAD LEFT"
		JOY_BUTTON_DPAD_RIGHT: return "D-PAD RIGHT"
		_: return "UNKNOWN GPAD"


static func get_mouse_button_string(button: MouseButton) -> String:
	match button:
		MOUSE_BUTTON_LEFT: return "LEFT MOUSE"
		MOUSE_BUTTON_RIGHT: return "RIGHT MOUSE"
		MOUSE_BUTTON_MIDDLE: return "MIDDLE MOUSE"
		MOUSE_BUTTON_WHEEL_UP: return "WHEEL UP"
		MOUSE_BUTTON_WHEEL_DOWN: return "WHEEL DOWN"
		MOUSE_BUTTON_XBUTTON1: return "MOUSE 4"
		MOUSE_BUTTON_XBUTTON2: return "MOUSE 5"
		_: return "UNKNOWN MOUSE"


static func get_joy_axis_string(axis: JoyAxis) -> String:
	match axis:
		JOY_AXIS_LEFT_X: return "LEFT STICK X"
		JOY_AXIS_LEFT_Y: return "LEFT STICK Y"
		JOY_AXIS_RIGHT_X: return "RIGHT STICK X"
		JOY_AXIS_RIGHT_Y: return "RIGHT STICK Y"
		JOY_AXIS_TRIGGER_LEFT: return "LEFT TRIGGER"
		JOY_AXIS_TRIGGER_RIGHT: return "RIGHT TRIGGER"
		_: return "UNKNOWN AXIS"
