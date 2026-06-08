class_name Tooltip extends PanelContainer

@onready var tip_label: RichTextLabel = %TipLabel

@export_category("Font settings")
@export var input_color: Color = Color.html("#f9ee00")
@export var action_color: Color = Color.html("#ffaf77")

enum InputType { Press, Hold, Move, Use }

var game_manager: GameManager

var oflag_input: String = "[color=#f9ee00]"
var oflag_action: String = "[color=#ffaf77]"
var player: Player
var cflag: String = "[/color]"


func _ready() -> void:
	visible = false
	oflag_input = "[color=#" + input_color.to_html() + "]"
	oflag_action = "[color=#" + action_color.to_html() + "]"
	ready_deffered.call_deferred()


func ready_deffered() -> void:
	game_manager = GameManager.instance
	if Player.instance: player = Player.instance
	else: game_manager.player_instance_loaded.connect(set_local_player, CONNECT_ONE_SHOT)


func set_local_player() -> void:
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
	if action == "move":  return InputType.Use
	if action == "run":
		var gpad_result: InputType = InputType.Press if player.is_run_toggle_gpad else InputType.Hold
		var km_result: InputType = InputType.Press if player.is_run_toggle else InputType.Hold
		return gpad_result if is_gpad else km_result
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
	if action == "move": return highlight_input("LEFT STICK" if is_gpad else "ZQSD")
	if action == "run": return highlight_input("L3" if is_gpad else "SHIFT") + ("" if is_gpad else " key")
	if action == "view": return highlight_input("RIGHT STICK" if is_gpad else "MOUSE")
	if action == "stand": action = "prone"
	if action == "open_bolt" or action == "close_bolt":
		var str_input: String = highlight_input("X" if is_gpad else "R") + (" button" if is_gpad else " key")
		return str_input + " at each square"
	var is_crouch_or_prone: bool = action == "crouch" or action == "prone"
	var events: Array[InputEvent] = InputMap.action_get_events(action)
	if is_gpad and is_crouch_or_prone: events = InputMap.action_get_events("gpad_switch_state")
	var input: String
	for event in events:
		if is_gpad and event is InputEventJoypadButton:
			input = highlight_input(Tools.joy_button_to_string((event as InputEventJoypadButton).button_index)) + " button"
			break
		if is_gpad and event is InputEventJoypadMotion:
			input = highlight_input(Tools.get_joy_axis_string((event as InputEventJoypadMotion).axis)) + " button"
			break
		elif not is_gpad and event is InputEventKey:
			input = highlight_input(OS.get_keycode_string((event as InputEventKey).physical_keycode)) + " key"
			break
		elif not is_gpad and event is InputEventMouseButton:
			input = highlight_input(Tools.get_mouse_button_string((event as InputEventMouseButton).button_index)) + " button"
	return input


func highlight_input(input_name: String) -> String:
	return oflag_input + input_name + cflag


func get_action_name(action: String) -> String:
	if action == "view": return highlight_action("Look around")
	if action == "open_bolt": return highlight_action("Open the bolt")
	if action == "close_bolt": return highlight_action("Close the bolt")
	return highlight_action(action.capitalize())


func highlight_action(action_name: String) -> String:
	return oflag_action + action_name + cflag
