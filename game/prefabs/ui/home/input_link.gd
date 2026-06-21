class_name InputLink extends Button

const INPUT_CONFIG_FILE_PATH = "user://input_map.ini"
const KEYBOARD_SECTION = "keyboard"
const GAMEPAD_SECTION = "gamepad"

@export var action: StringName
@export var gamepad: bool = false

var _current_event: InputEvent = null
var _is_waiting_for_new_input: bool = false

func _ready() -> void:
	pressed.connect(_wait_for_input)
	var events: Array[InputEvent] = InputMap.action_get_events(action)
	assert(events.size(), "There is not event linked to %s action" % action)
	_current_event = _get_current_input_map_event()
	_load_input()
	_update_icon()

func _wait_for_input() -> void:
	_is_waiting_for_new_input = true
	disabled = true

func _unhandled_input(event: InputEvent) -> void:
	if not _is_waiting_for_new_input: return

	if event is InputEventKey and (event as InputEventKey).keycode == KEY_ESCAPE:
		_is_waiting_for_new_input = false
		disabled = false
		return

	if event is InputEventKey or event is InputEventJoypadButton:
		if event is InputEventKey and gamepad: return
		if event is InputEventJoypadButton and not gamepad: return
		if _current_event: InputMap.action_erase_event(action, _current_event)
		InputMap.action_add_event(action, event)
		_current_event = event
		_save_input()
		disabled = false
		_update_icon()
		_is_waiting_for_new_input = false

func _get_current_input_map_event() -> InputEvent:
	var events: Array[InputEvent] = InputMap.action_get_events(action)
	for event: InputEvent in events:
		if event is InputEventKey and not gamepad: return event
		if event is InputEventJoypadButton and gamepad: return event
	return null

func _load_input() -> void:
	var config_file := ConfigFile.new()
	var error: Error = config_file.load(INPUT_CONFIG_FILE_PATH)
	if error != OK: return

	var section: String = _get_config_section()
	var key: String = str(action)
	if not config_file.has_section_key(section, key): return

	var event_data: Variant = config_file.get_value(section, key)
	if not event_data is Dictionary: return

	var event: InputEvent = _event_from_dictionary(event_data)
	if not event: return

	if _current_event: InputMap.action_erase_event(action, _current_event)
	InputMap.action_add_event(action, event)
	_current_event = event

func _save_input() -> void:
	if not _current_event: return

	var config_file := ConfigFile.new()
	config_file.load(INPUT_CONFIG_FILE_PATH)
	config_file.set_value(_get_config_section(), str(action), _event_to_dictionary(_current_event))
	var error: Error = config_file.save(INPUT_CONFIG_FILE_PATH)
	if error != OK:
		push_warning("Failed to save input map to %s: %s" % [INPUT_CONFIG_FILE_PATH, error])

func _get_config_section() -> String:
	return GAMEPAD_SECTION if gamepad else KEYBOARD_SECTION

func _update_icon() -> void:
	if not _current_event: 
		icon = null
		text = ""
		return
		
	icon = Inputs.get_icon(_current_event)
	if icon: text = ""
	else:
		if gamepad:
			text = str((_current_event as InputEventJoypadButton).button_index)
		else:
			text = OS.get_keycode_string((DisplayServer.keyboard_get_keycode_from_physical((_current_event as InputEventKey).physical_keycode)))


func _event_to_dictionary(event: InputEvent) -> Dictionary:
	if event is InputEventKey:
		var key_event: InputEventKey = event as InputEventKey
		return {
			"type": "key",
			"keycode": key_event.keycode,
			"physical_keycode": key_event.physical_keycode,
			"key_label": key_event.key_label,
			"location": key_event.location,
			"ctrl_pressed": key_event.ctrl_pressed,
			"shift_pressed": key_event.shift_pressed,
			"alt_pressed": key_event.alt_pressed,
			"meta_pressed": key_event.meta_pressed,
		}
	if event is InputEventJoypadButton:
		var joypad_event: InputEventJoypadButton = event as InputEventJoypadButton
		return {
			"type": "joypad_button",
			"button_index": joypad_event.button_index,
		}
	return {}

func _event_from_dictionary(event_data: Dictionary) -> InputEvent:
	match event_data.get("type", ""):
		"key":
			if gamepad: return null
			var key_event: InputEventKey = InputEventKey.new()
			key_event.keycode = event_data.get("keycode", KEY_NONE)
			key_event.physical_keycode = event_data.get("physical_keycode", KEY_NONE)
			key_event.key_label = event_data.get("key_label", KEY_NONE)
			key_event.location = event_data.get("location", KEY_LOCATION_UNSPECIFIED)
			key_event.ctrl_pressed = event_data.get("ctrl_pressed", false)
			key_event.shift_pressed = event_data.get("shift_pressed", false)
			key_event.alt_pressed = event_data.get("alt_pressed", false)
			key_event.meta_pressed = event_data.get("meta_pressed", false)
			return key_event
		"joypad_button":
			if not gamepad: return null
			var joypad_event: InputEventJoypadButton = InputEventJoypadButton.new()
			joypad_event.button_index = event_data.get("button_index", JOY_BUTTON_INVALID)
			return joypad_event
	return null
