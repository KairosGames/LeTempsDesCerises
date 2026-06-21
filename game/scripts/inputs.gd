class_name Inputs extends Node

const KEYBOARD_S: Texture2D = preload("uid://bepur26ilvyxg")
const KEYBOARD_A: Texture2D = preload("uid://b7hqrp7h3vvkw")
const KEYBOARD_D: Texture2D = preload("uid://dlbo2jl3rjvwh")
const KEYBOARD_W: Texture2D = preload("uid://dntkk8f0htx0x")
const KEYBOARD_SPACE: Texture2D = preload("uid://0cbfn8tykaun")
const KEYBOARD_C: Texture2D = preload("uid://jksmwbsksk5x")
const KEYBOARD_X: Texture2D = preload("uid://caq272qwmtvu7")
const KEYBOARD_SHIFT: Texture2D = preload("uid://dx68rie1e1k0s")

static func get_icon(event: InputEvent) -> Texture2D:
	if event is InputEventJoypadButton: return null
	if event is InputEventKey:
		#match (event as InputEventKey).physical_keycode: 87: return KEYBOARD_W
		return null
	return null
