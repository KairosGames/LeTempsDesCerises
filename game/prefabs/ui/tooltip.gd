class_name Tooltip extends PanelContainer

@onready var tip_label: Label = %TipLabel

enum InputType { Press, Hold, Move }

var player: Player


func _ready() -> void:
	visible = false
	ready_deffered.call_deferred()


func ready_deffered() -> void:
	player = Player.instance


func set_label(action: String, is_gpad: bool) -> void:
	var action_type: InputType = get_input_type(action, is_gpad)
	var input_name: String = get_input_name(action, is_gpad)
	var action_name: String = get_action_name(action)
	tip_label.text = InputType.keys()[action_type] + " " + input_name + " to " + action_name


func display(is_display: bool) -> void:
	visible = is_display


func get_input_type(action: String, is_gpad: bool) -> InputType:
	var result: InputType
	if action == "stand": action = "prone"
	if action == "open_bolt" or action == "close_bolt": action = "reload"
	match action:
		"prone":
			result = InputType.Hold if is_gpad else InputType.Press
		"aim":
			var gpad_result: InputType = InputType.Press if player.is_aim_toggle_gpad else InputType.Hold
			var km_result: InputType = InputType.Press if player.is_aim_toggle_km else InputType.Hold
			result = gpad_result if is_gpad else km_result
		"view":
			result = InputType.Move
		_:
			result = InputType.Press
	return result


func get_input_name(action: String, is_gpad: bool) -> String:
	if action == "view": return "Right Stick" if is_gpad else "Mouse"
	if action == "stand": action = "prone"
	if action == "open_bolt" or action == "close_bolt":
		var str_input: String = "X button" if is_gpad else "R key"
		return str_input + " at each square"
	var is_crouch_or_prone: bool = action == "crouch" or action == "prone"
	var events: Array[InputEvent] = InputMap.action_get_events(action)
	if is_gpad and is_crouch_or_prone: events = InputMap.action_get_events("gpad_switch_state")
	var input: String
	for event in events:
		if is_gpad and event is InputEventJoypadButton:
			input = Tools.joy_button_to_string((event as InputEventJoypadButton).button_index) + " button"
			break
		if is_gpad and event is InputEventJoypadMotion:
			input = Tools.get_joy_axis_string((event as InputEventJoypadMotion).axis) + " button"
			break
		elif not is_gpad and event is InputEventKey:
			input = OS.get_keycode_string((event as InputEventKey).physical_keycode) + " key"
			break
		elif not is_gpad and event is InputEventMouseButton:
			input = Tools.get_mouse_button_string((event as InputEventMouseButton).button_index) + " button"
	return input


func get_action_name(action: String) -> String:
	if action == "view": return "Look around"
	if action == "open_bolt": return "Open the bolt"
	if action == "close_bolt": return "Close the bolt"
	return action.capitalize()
