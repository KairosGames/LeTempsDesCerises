class_name Inputs extends Node

const KEYBOARD_A: Texture2D = preload("uid://b7hqrp7h3vvkw")
const KEYBOARD_B: Texture2D = preload("uid://bdn4cyx3x4uu")
const KEYBOARD_C: Texture2D = preload("uid://jksmwbsksk5x")
const KEYBOARD_D: Texture2D = preload("uid://dlbo2jl3rjvwh")
const KEYBOARD_E: Texture2D = preload("uid://lllpn2wwcbu5")
const KEYBOARD_F: Texture2D = preload("uid://ci0tb7xetraw0")
const KEYBOARD_G: Texture2D = preload("uid://58o7vkarkya2")
const KEYBOARD_H: Texture2D = preload("uid://cwmsirob01wpb")
const KEYBOARD_I: Texture2D = preload("uid://uyxrafrlenn1")
const KEYBOARD_J: Texture2D = preload("uid://2mdxs6smntm0")
const KEYBOARD_K: Texture2D = preload("uid://cll4k7jneb5vj")
const KEYBOARD_L: Texture2D = preload("uid://d1s6v2kimbp45")
const KEYBOARD_M: Texture2D = preload("uid://cantgjdxvjrho")
const KEYBOARD_N: Texture2D = preload("uid://bnv2cwrlkefbl")
const KEYBOARD_O: Texture2D = preload("uid://bms37iq5taobt")
const KEYBOARD_P: Texture2D = preload("uid://bup8txhklh4aw")
const KEYBOARD_Q: Texture2D = preload("uid://ctn32yaiq54n5")
const KEYBOARD_R: Texture2D = preload("uid://crgngp83cu34k")
const KEYBOARD_S: Texture2D = preload("uid://bepur26ilvyxg")
const KEYBOARD_T: Texture2D = preload("uid://wftiudubrylk")
const KEYBOARD_U: Texture2D = preload("uid://b2pcsm1xohjr0")
const KEYBOARD_V: Texture2D = preload("uid://cg5404n0kc7o")
const KEYBOARD_W: Texture2D = preload("uid://dntkk8f0htx0x")
const KEYBOARD_X: Texture2D = preload("uid://caq272qwmtvu7")
const KEYBOARD_Y: Texture2D = preload("uid://sog8udq5wfpr")
const KEYBOARD_Z: Texture2D = preload("uid://dxjdgccq87jks")
const KEYBOARD_SPACE: Texture2D = preload("uid://0cbfn8tykaun")
const KEYBOARD_SHIFT: Texture2D = preload("uid://dx68rie1e1k0s")
const KEYBOARD_ESCAPE: Texture2D = preload("uid://cav4fdhcxm26p")
const KEYBOARD_CTRL: Texture2D = preload("uid://dewdsshxyna01")
const KEYBOARD_ALT: Texture2D = preload("uid://csoees8b3xrnj")
const KEYBOARD_ARROW_RIGHT: Texture2D = preload("uid://dgmny4c0nlnt")
const KEYBOARD_F7: Texture2D = preload("uid://dfk5cy5w53pkt")
const KEYBOARD_F8: Texture2D = preload("uid://x8shgpqg3cv7")
const KEYBOARD_F9: Texture2D = preload("uid://b4jten35er8g8")

const GAMEPAD_A: Texture2D = preload("uid://do6ip18g02nv5")
const GAMEPAD_B: Texture2D = preload("uid://cw0lt5fxl7pjg")
const GAMEPAD_X: Texture2D = preload("uid://ct0haval6vov7")
const GAMEPAD_Y: Texture2D = preload("uid://dvvfskhe23nok")
const GAMEPAD_BACK: Texture2D = preload("uid://brl2uue7ccfvo")
const GAMEPAD_GUIDE: Texture2D = preload("uid://dg8cs36fdx3d5")
const GAMEPAD_START: Texture2D = preload("uid://dnlqq5ymivnjr")
const GAMEPAD_LEFT_STICK: Texture2D = preload("uid://d07bay1c0cp2j")
const GAMEPAD_RIGHT_STICK: Texture2D = preload("uid://bp8wecv834k78")
const GAMEPAD_LEFT_SHOULDER: Texture2D = preload("uid://dk6x2xw8d4xon")
const GAMEPAD_RIGHT_SHOULDER: Texture2D = preload("uid://du2iid4r0lkrx")
const GAMEPAD_DPAD_UP: Texture2D = preload("uid://vh8ugpeldrvv")
const GAMEPAD_DPAD_DOWN: Texture2D = preload("uid://biv4fmum7ejph")
const GAMEPAD_DPAD_LEFT: Texture2D = preload("uid://d3jnar28nkixv")
const GAMEPAD_DPAD_RIGHT: Texture2D = preload("uid://cgiauuk1euyoh")
const GAMEPAD_MISC: Texture2D = preload("uid://dovrk4m2ekkb4")
const GAMEPAD_PADDLE_BOTTOM_RIGHT: Texture2D = preload("uid://dtlyas53ad23m")
const GAMEPAD_PADDLE_TOP_RIGHT: Texture2D = preload("uid://c2lfr1pyrg7hb")
const GAMEPAD_PADDLE_BOTTOM_LEFT: Texture2D = preload("uid://ce11rrw6ahwg7")
const GAMEPAD_PADDLE_TOP_LEFT: Texture2D = preload("uid://0fjkuh3wu8wi")
const GAMEPAD_LEFT_TRIGGER: Texture2D = preload("uid://dncgnv6rb1fmc")
const GAMEPAD_RIGHT_TRIGGER: Texture2D = preload("uid://jxrdryy2825r")
const GAMEPAD_LEFT_STICK_UP: Texture2D = preload("uid://bh8077s5li28v")
const GAMEPAD_LEFT_STICK_DOWN: Texture2D = preload("uid://dniutdrwgq3vd")
const GAMEPAD_LEFT_STICK_LEFT: Texture2D = preload("uid://q8m51qjuvggm")
const GAMEPAD_LEFT_STICK_RIGHT: Texture2D = preload("uid://egxoxa7ybwqe")
const GAMEPAD_RIGHT_STICK_UP: Texture2D = preload("uid://wcorqjnoroy1")
const GAMEPAD_RIGHT_STICK_DOWN: Texture2D = preload("uid://cigg6sg0qe0fs")
const GAMEPAD_RIGHT_STICK_LEFT: Texture2D = preload("uid://bxmeuu0wig0nr")
const GAMEPAD_RIGHT_STICK_RIGHT: Texture2D = preload("uid://c5wo84r78wied")

static func get_icon(event: InputEvent) -> Texture2D:
	if event is InputEventJoypadButton:
		return _get_gamepad_button_icon((event as InputEventJoypadButton).button_index)
	if event is InputEventJoypadMotion:
		var joypad_motion_event: InputEventJoypadMotion = event as InputEventJoypadMotion
		return _get_gamepad_motion_icon(joypad_motion_event.axis, joypad_motion_event.axis_value)
	if event is InputEventKey:
		return _get_keyboard_icon(_get_display_key(event as InputEventKey))
	return null

static func _get_display_key(event: InputEventKey) -> Key:
	if event.key_label != KEY_NONE: return event.key_label
	if event.keycode != KEY_NONE: return event.keycode
	if event.physical_keycode != KEY_NONE:
		if DisplayServer.get_name() == "headless":
			return event.physical_keycode
		return DisplayServer.keyboard_get_keycode_from_physical(event.physical_keycode)
	return KEY_NONE

static func _get_keyboard_icon(key: Key) -> Texture2D:
	match key:
		KEY_A: return KEYBOARD_A
		KEY_B: return KEYBOARD_B
		KEY_C: return KEYBOARD_C
		KEY_D: return KEYBOARD_D
		KEY_E: return KEYBOARD_E
		KEY_F: return KEYBOARD_F
		KEY_G: return KEYBOARD_G
		KEY_H: return KEYBOARD_H
		KEY_I: return KEYBOARD_I
		KEY_J: return KEYBOARD_J
		KEY_K: return KEYBOARD_K
		KEY_L: return KEYBOARD_L
		KEY_M: return KEYBOARD_M
		KEY_N: return KEYBOARD_N
		KEY_O: return KEYBOARD_O
		KEY_P: return KEYBOARD_P
		KEY_Q: return KEYBOARD_Q
		KEY_R: return KEYBOARD_R
		KEY_S: return KEYBOARD_S
		KEY_T: return KEYBOARD_T
		KEY_U: return KEYBOARD_U
		KEY_V: return KEYBOARD_V
		KEY_W: return KEYBOARD_W
		KEY_X: return KEYBOARD_X
		KEY_Y: return KEYBOARD_Y
		KEY_Z: return KEYBOARD_Z
		KEY_SPACE: return KEYBOARD_SPACE
		KEY_SHIFT: return KEYBOARD_SHIFT
		KEY_ESCAPE: return KEYBOARD_ESCAPE
		KEY_CTRL: return KEYBOARD_CTRL
		KEY_ALT: return KEYBOARD_ALT
		KEY_RIGHT: return KEYBOARD_ARROW_RIGHT
		KEY_F7: return KEYBOARD_F7
		KEY_F8: return KEYBOARD_F8
		KEY_F9: return KEYBOARD_F9
	return null

static func _get_gamepad_button_icon(button_index: JoyButton) -> Texture2D:
	match button_index:
		JOY_BUTTON_A: return GAMEPAD_A
		JOY_BUTTON_B: return GAMEPAD_B
		JOY_BUTTON_X: return GAMEPAD_X
		JOY_BUTTON_Y: return GAMEPAD_Y
		JOY_BUTTON_BACK: return GAMEPAD_BACK
		JOY_BUTTON_GUIDE: return GAMEPAD_GUIDE
		JOY_BUTTON_START: return GAMEPAD_START
		JOY_BUTTON_LEFT_STICK: return GAMEPAD_LEFT_STICK
		JOY_BUTTON_RIGHT_STICK: return GAMEPAD_RIGHT_STICK
		JOY_BUTTON_LEFT_SHOULDER: return GAMEPAD_LEFT_SHOULDER
		JOY_BUTTON_RIGHT_SHOULDER: return GAMEPAD_RIGHT_SHOULDER
		JOY_BUTTON_DPAD_UP: return GAMEPAD_DPAD_UP
		JOY_BUTTON_DPAD_DOWN: return GAMEPAD_DPAD_DOWN
		JOY_BUTTON_DPAD_LEFT: return GAMEPAD_DPAD_LEFT
		JOY_BUTTON_DPAD_RIGHT: return GAMEPAD_DPAD_RIGHT
		JOY_BUTTON_MISC1: return GAMEPAD_MISC
		JOY_BUTTON_PADDLE1: return GAMEPAD_PADDLE_BOTTOM_RIGHT
		JOY_BUTTON_PADDLE2: return GAMEPAD_PADDLE_TOP_RIGHT
		JOY_BUTTON_PADDLE3: return GAMEPAD_PADDLE_BOTTOM_LEFT
		JOY_BUTTON_PADDLE4: return GAMEPAD_PADDLE_TOP_LEFT
		JOY_BUTTON_TOUCHPAD: return GAMEPAD_MISC
	return null

static func _get_gamepad_motion_icon(axis: JoyAxis, axis_value: float) -> Texture2D:
	match axis:
		JOY_AXIS_LEFT_X:
			return GAMEPAD_LEFT_STICK_RIGHT if axis_value > 0.0 else GAMEPAD_LEFT_STICK_LEFT
		JOY_AXIS_LEFT_Y:
			return GAMEPAD_LEFT_STICK_DOWN if axis_value > 0.0 else GAMEPAD_LEFT_STICK_UP
		JOY_AXIS_RIGHT_X:
			return GAMEPAD_RIGHT_STICK_RIGHT if axis_value > 0.0 else GAMEPAD_RIGHT_STICK_LEFT
		JOY_AXIS_RIGHT_Y:
			return GAMEPAD_RIGHT_STICK_DOWN if axis_value > 0.0 else GAMEPAD_RIGHT_STICK_UP
		JOY_AXIS_TRIGGER_LEFT:
			return GAMEPAD_LEFT_TRIGGER
		JOY_AXIS_TRIGGER_RIGHT:
			return GAMEPAD_RIGHT_TRIGGER
	return null
