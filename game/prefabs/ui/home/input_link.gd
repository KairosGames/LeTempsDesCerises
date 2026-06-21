class_name InputLink extends Button

const INPUT_CONFIG_FILE_PATH = "user://input_map.ini"
const KEYBOARD_SECTION = "keyboard"
const GAMEPAD_SECTION = "gamepad"

@export var action: StringName
@export var gamepad: bool = false

static var _default_events: Dictionary = {}

var _current_event: InputEvent = null
var _is_waiting_for_new_input: bool = false

func _ready() -> void:
	pressed.connect(_wait_for_input)
	var events: Array[InputEvent] = InputMap.action_get_events(action)
	assert(events.size(), "There is not event linked to %s action" % action)
	_current_event = _get_current_input_map_event()
	_save_default_input()
	_load_input()
	_connect_revert_button()
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

	if event is InputEventKey or event is InputEventJoypadButton or event is InputEventJoypadMotion:
		if event is InputEventKey and gamepad: return
		if (event is InputEventJoypadButton or event is InputEventJoypadMotion) and not gamepad: return
		if event is InputEventJoypadMotion and absf((event as InputEventJoypadMotion).axis_value) < 0.5: return
		if _current_event: InputMap.action_erase_event(action, _current_event)
		InputMap.action_add_event(action, event)
		_current_event = event
		_save_input()
		disabled = false
		_update_icon()
		_is_waiting_for_new_input = false

func reset_to_default() -> void:
	var default_event: InputEvent = _get_default_input()
	if _current_event: InputMap.action_erase_event(action, _current_event)
	if default_event:
		InputMap.action_add_event(action, default_event)
	_current_event = default_event
	_remove_saved_input()
	_update_icon()

func _get_current_input_map_event() -> InputEvent:
	var events: Array[InputEvent] = InputMap.action_get_events(action)
	for event: InputEvent in events:
		if event is InputEventKey and not gamepad: return event
		if (event is InputEventJoypadButton or event is InputEventJoypadMotion) and gamepad: return event
	return null

func _save_default_input() -> void:
	var key: String = _get_default_input_key()
	if _default_events.has(key): return
	_default_events[key] = _current_event.duplicate() if _current_event else null

func _get_default_input() -> InputEvent:
	var default_event: InputEvent = _default_events.get(_get_default_input_key(), null)
	return default_event.duplicate() if default_event else null

func _get_default_input_key() -> String:
	return "%s/%s" % [_get_config_section(), action]

func _connect_revert_button() -> void:
	var parent_node := get_parent()
	if not parent_node: return
	if parent_node.get_meta("input_link_revert_connected", false): return
	var revert_button := parent_node.get_node_or_null("Revert") as Button
	if not revert_button: return
	parent_node.set_meta("input_link_revert_connected", true)
	revert_button.pressed.connect(_reset_parent_input_links.bind(parent_node))

func _reset_parent_input_links(parent_node: Node) -> void:
	for child: Node in parent_node.get_children():
		if child is InputLink:
			(child as InputLink).reset_to_default()

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
	_save_config_file(config_file)

func _remove_saved_input() -> void:
	var config_file := ConfigFile.new()
	config_file.load(INPUT_CONFIG_FILE_PATH)
	var section: String = _get_config_section()
	var key: String = str(action)
	if config_file.has_section_key(section, key):
		config_file.erase_section_key(section, key)
		_save_config_file(config_file)

func _save_config_file(config_file: ConfigFile) -> void:
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
			if _current_event is InputEventJoypadButton:
				text = str((_current_event as InputEventJoypadButton).button_index)
			elif _current_event is InputEventJoypadMotion:
				var joypad_motion_event: InputEventJoypadMotion = _current_event as InputEventJoypadMotion
				text = "Axis %s %s" % [joypad_motion_event.axis, "+" if joypad_motion_event.axis_value > 0.0 else "-"]
		else:
			text = OS.get_keycode_string(_get_display_key(_current_event as InputEventKey))

func _get_display_key(event: InputEventKey) -> Key:
	if event.key_label != KEY_NONE: return event.key_label
	if event.keycode != KEY_NONE: return event.keycode
	if event.physical_keycode != KEY_NONE:
		return DisplayServer.keyboard_get_keycode_from_physical(event.physical_keycode)
	return KEY_NONE

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
	if event is InputEventJoypadMotion:
		var joypad_motion_event: InputEventJoypadMotion = event as InputEventJoypadMotion
		return {
			"type": "joypad_motion",
			"axis": joypad_motion_event.axis,
			"axis_value": 1.0 if joypad_motion_event.axis_value > 0.0 else -1.0,
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
		"joypad_motion":
			if not gamepad: return null
			var joypad_motion_event: InputEventJoypadMotion = InputEventJoypadMotion.new()
			joypad_motion_event.axis = event_data.get("axis", JOY_AXIS_LEFT_X)
			joypad_motion_event.axis_value = event_data.get("axis_value", 1.0)
			return joypad_motion_event
	return null
