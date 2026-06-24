extends VBoxContainer

const LANGUAGE_LABELS: Array[String] = ["French", "English"]
const LANGUAGE_VALUES: Array[String] = ["French(France)", "English(US)"]

const SLIDERS: Dictionary = {
	"sensi_default": {
		"slider_path": ^"ScrollContainer/Settings/Common/ViewSensibility/Slider",
		"label_path": ^"ScrollContainer/Settings/Common/ViewSensibility/Value",
	},
	"sensi_aiming": {
		"slider_path": ^"ScrollContainer/Settings/Common/AimingSensibility/Slider",
		"label_path": ^"ScrollContainer/Settings/Common/AimingSensibility/Value",
	},
	"h_sensi_multiplier": {
		"slider_path": ^"ScrollContainer/Settings/Common/HMultiplier/Slider",
		"label_path": ^"ScrollContainer/Settings/Common/HMultiplier/Value",
	},
	"v_sensi_multiplier": {
		"slider_path": ^"ScrollContainer/Settings/Common/VMultiplier/Slider",
		"label_path": ^"ScrollContainer/Settings/Common/VMultiplier/Value",
	},
	"l_jstick_threshold": {
		"slider_path": ^"ScrollContainer/Settings/Gamepad/DeadzoneLeftStick/Slider",
		"label_path": ^"ScrollContainer/Settings/Gamepad/DeadzoneLeftStick/Value",
	},
	"r_jstick_threshold": {
		"slider_path": ^"ScrollContainer/Settings/Gamepad/DeadzoneRightStick/Slider",
		"label_path": ^"ScrollContainer/Settings/Gamepad/DeadzoneRightStick/Value",
	},
}

const TOGGLES: Dictionary = {
	"allow_subtitles": ^"ScrollContainer/Settings/General/Subtitles/CheckButton",
	"is_blood_enabled": ^"ScrollContainer/Settings/General/Blood/CheckButton",
	"is_inverted": ^"ScrollContainer/Settings/Common/Inverted/CheckButton",
	"is_aim_toggle_km": ^"ScrollContainer/Settings/Keyboard/AimToggleKM/CheckButton",
	"is_run_toggle_km": ^"ScrollContainer/Settings/Keyboard/RunToggleKM/CheckButton",
	"is_aim_toggle_gpad": ^"ScrollContainer/Settings/Gamepad/AimToggleGamepad/CheckButton",
	"is_run_toggle_gpad": ^"ScrollContainer/Settings/Gamepad/RunToggleGamepad/CheckButton",
	"is_posture_switch_toggle_km": ^"ScrollContainer/Settings/Gameplay/PostureSwitchToggleKM/CheckButton",
	"is_aim_smooth": ^"ScrollContainer/Settings/Gameplay/AimSmooth/CheckButton",
	"is_movement_smooth": ^"ScrollContainer/Settings/Gameplay/MovementSmooth/CheckButton",
}

@onready var reset_button: Button = %GameReset
@onready var language_previous_button: Button = get_node(^"ScrollContainer/Settings/General/Language/Previous")
@onready var language_value_label: Label = get_node(^"ScrollContainer/Settings/General/Language/Value")
@onready var language_next_button: Button = get_node(^"ScrollContainer/Settings/General/Language/Next")

var _language_index: int = 0


func _ready() -> void:
	_connect_controls()
	load_game_settings()


func load_game_settings() -> void:
	var current_language: String = str(Settings.call("get_language"))
	_language_index = _find_language_index(current_language)
	_apply_language_label()

	for key_variant: Variant in SLIDERS.keys():
		var key: String = key_variant as String
		var row: Dictionary = SLIDERS[key] as Dictionary
		var slider: HSlider = get_node(row["slider_path"] as NodePath)
		var label: Label = get_node(row["label_path"] as NodePath)
		_set_slider_value(slider, label, _game_setting_float(key))

	for key_variant: Variant in TOGGLES.keys():
		var key: String = key_variant as String
		var button: CheckButton = get_node(TOGGLES[key] as NodePath)
		button.set_pressed_no_signal(_game_setting_bool(key))

	WwiseGlobal.allow_subtitles = _game_setting_bool("allow_subtitles")


func _connect_controls() -> void:
	for key_variant: Variant in SLIDERS.keys():
		var key: String = key_variant as String
		var row: Dictionary = SLIDERS[key] as Dictionary
		var slider: HSlider = get_node(row["slider_path"] as NodePath)
		slider.value_changed.connect(_on_slider_changed.bind(key))

	for key_variant: Variant in TOGGLES.keys():
		var key: String = key_variant as String
		var button: CheckButton = get_node(TOGGLES[key] as NodePath)
		button.toggled.connect(_on_toggle_changed.bind(key))

	language_previous_button.pressed.connect(_on_language_step_pressed.bind(-1))
	language_next_button.pressed.connect(_on_language_step_pressed.bind(1))
	reset_button.pressed.connect(_on_reset_pressed)


func _on_slider_changed(value: float, key: String) -> void:
	var row: Dictionary = SLIDERS[key] as Dictionary
	var slider: HSlider = get_node(row["slider_path"] as NodePath)
	var label: Label = get_node(row["label_path"] as NodePath)
	label.text = _format_slider_value(slider, value)
	var settings_config: ConfigFile = Settings.get("config_file") as ConfigFile
	settings_config.set_value("game", key, value)
	Settings.call("save_settings")


func _on_toggle_changed(toggled_on: bool, key: String) -> void:
	if key == "allow_subtitles":
		WwiseGlobal.allow_subtitles = toggled_on
	var settings_config: ConfigFile = Settings.get("config_file") as ConfigFile
	settings_config.set_value("game", key, toggled_on)
	Settings.call("save_settings")


func _on_language_step_pressed(direction: int) -> void:
	_language_index = wrapi(_language_index + direction, 0, LANGUAGE_VALUES.size())
	_apply_language_label()
	Settings.call("set_language", LANGUAGE_VALUES[_language_index])


func _on_reset_pressed() -> void:
	var defaults: Dictionary = Settings.get("DEFAULTS") as Dictionary
	var game_defaults: Dictionary = defaults.get("game", {}) as Dictionary
	var settings_config: ConfigFile = Settings.get("config_file") as ConfigFile
	for key_variant: Variant in game_defaults.keys():
		var key: String = str(key_variant)
		settings_config.set_value("game", key, game_defaults[key])
	Settings.call("save_settings")
	Settings.language_changed.emit(str(Settings.call("get_language")))
	load_game_settings()
	reset_button.grab_focus()


func _set_slider_value(slider: HSlider, label: Label, value: float) -> void:
	slider.set_value_no_signal(value)
	label.text = _format_slider_value(slider, value)


func _format_slider_value(slider: Range, value: float) -> String:
	var decimals: int = 0
	if not is_zero_approx(slider.step):
		var step_text: String = String.num(slider.step, 4).rstrip("0")
		var separator_index: int = step_text.find(".")
		if separator_index >= 0:
			decimals = step_text.length() - separator_index - 1
	return String.num(value, decimals)


func _game_setting_float(key: String) -> float:
	var settings_config: ConfigFile = Settings.get("config_file") as ConfigFile
	var value: Variant = settings_config.get_value("game", key)
	if value is int:
		return value as float
	if value is float:
		return value
	if value is bool:
		return 1.0 if value else 0.0
	return 0.0


func _game_setting_bool(key: String) -> bool:
	var settings_config: ConfigFile = Settings.get("config_file") as ConfigFile
	var value: Variant = settings_config.get_value("game", key)
	if value is bool:
		return value
	if value is int:
		return value != 0
	if value is float:
		return not is_zero_approx(value as float)
	return false


func _find_language_index(language: String) -> int:
	var language_index: int = LANGUAGE_VALUES.find(language)
	if language_index == -1:
		return 0
	return language_index


func _apply_language_label() -> void:
	language_value_label.text = LANGUAGE_LABELS[_language_index]
