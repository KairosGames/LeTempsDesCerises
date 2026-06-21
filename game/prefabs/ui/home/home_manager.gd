class_name HomeManager extends Control

@onready var references: PanelContainer = %References
@onready var credit: PanelContainer = %Credit
@onready var option: TabContainer = %Option
@onready var menu: PanelContainer = $Menu

@onready var play: ButtonBehavior = $Menu/Buttons/Play

@onready var view_sensibility_slider: HSlider = option.get_node(^"GAME/ViewSensibility/Slider")
@onready var aiming_sensibility_slider: HSlider = option.get_node(^"GAME/AimingSensibility/Slider")
@onready var inverted_check_button: CheckButton = option.get_node(^"GAME/Inverted/CheckButton")
@onready var h_multiplier_slider: HSlider = option.get_node(^"GAME/HMultiplier/Slider")
@onready var v_multiplier_slider: HSlider = option.get_node(^"GAME/VMultiplier/Slider")
@onready var left_stick_deadzone_slider: HSlider = option.get_node(^"GAME/DeadzoneLeftStick/Slider")
@onready var right_stick_deadzone_slider: HSlider = option.get_node(^"GAME/DeadzoneRightStick/Slider")
@onready var aim_toggle_km_check_button: CheckButton = option.get_node(^"GAME/AimToggleKM/CheckButton")
@onready var run_toggle_km_check_button: CheckButton = option.get_node(^"GAME/RunToggleKM/CheckButton")
@onready var aim_toggle_gpad_check_button: CheckButton = option.get_node(^"GAME/AimToggleGamepad/CheckButton")
@onready var run_toggle_gpad_check_button: CheckButton = option.get_node(^"GAME/RunToggleGamepad/CheckButton")
@onready var posture_switch_toggle_km_check_button: CheckButton = option.get_node(^"GAME/PostureSwitchToggleKM/CheckButton")
@onready var aim_smooth_check_button: CheckButton = option.get_node(^"GAME/AimSmooth/CheckButton")
@onready var movement_smooth_check_button: CheckButton = option.get_node(^"GAME/MovementSmooth/CheckButton")

func _ready() -> void:
	play.grab_focus()
	_load_game_settings_controls()
	view_sensibility_slider.value_changed.connect(_on_game_slider_changed.bind("sensi_default"))
	aiming_sensibility_slider.value_changed.connect(_on_game_slider_changed.bind("sensi_aiming"))
	inverted_check_button.toggled.connect(_on_inverted_toggled)
	h_multiplier_slider.value_changed.connect(_on_game_slider_changed.bind("h_sensi_multiplier"))
	v_multiplier_slider.value_changed.connect(_on_game_slider_changed.bind("v_sensi_multiplier"))
	left_stick_deadzone_slider.value_changed.connect(_on_game_slider_changed.bind("l_jstick_threshold"))
	right_stick_deadzone_slider.value_changed.connect(_on_game_slider_changed.bind("r_jstick_threshold"))
	aim_toggle_km_check_button.toggled.connect(_on_game_toggle_changed.bind("is_aim_toggle_km"))
	run_toggle_km_check_button.toggled.connect(_on_game_toggle_changed.bind("is_run_toggle_km"))
	aim_toggle_gpad_check_button.toggled.connect(_on_game_toggle_changed.bind("is_aim_toggle_gpad"))
	run_toggle_gpad_check_button.toggled.connect(_on_game_toggle_changed.bind("is_run_toggle_gpad"))
	posture_switch_toggle_km_check_button.toggled.connect(_on_game_toggle_changed.bind("is_posture_switch_toggle_km"))
	aim_smooth_check_button.toggled.connect(_on_game_toggle_changed.bind("is_aim_smooth"))
	movement_smooth_check_button.toggled.connect(_on_game_toggle_changed.bind("is_movement_smooth"))

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("uid://bqw181keq72d")


func _on_options_pressed() -> void:
	_load_game_settings_controls()
	menu.hide()
	option.show()
	references.hide()
	credit.hide()


func _on_referecences_pressed() -> void:
	menu.hide()
	references.show()
	option.hide()
	credit.hide()


func _on_credits_pressed() -> void:
	menu.hide()
	credit.show()
	option.hide()
	references.hide()


func _on_quit_pressed() -> void:
	get_tree().quit()


func _load_game_settings_controls() -> void:
	view_sensibility_slider.set_value_no_signal(Settings.config_file.get_value("game", "sensi_default"))
	aiming_sensibility_slider.set_value_no_signal(Settings.config_file.get_value("game", "sensi_aiming"))
	inverted_check_button.set_pressed_no_signal(Settings.config_file.get_value("game", "is_inverted"))
	h_multiplier_slider.set_value_no_signal(Settings.config_file.get_value("game", "h_sensi_multiplier"))
	v_multiplier_slider.set_value_no_signal(Settings.config_file.get_value("game", "v_sensi_multiplier"))
	left_stick_deadzone_slider.set_value_no_signal(Settings.config_file.get_value("game", "l_jstick_threshold"))
	right_stick_deadzone_slider.set_value_no_signal(Settings.config_file.get_value("game", "r_jstick_threshold"))
	aim_toggle_km_check_button.set_pressed_no_signal(Settings.config_file.get_value("game", "is_aim_toggle_km"))
	run_toggle_km_check_button.set_pressed_no_signal(Settings.config_file.get_value("game", "is_run_toggle_km"))
	aim_toggle_gpad_check_button.set_pressed_no_signal(Settings.config_file.get_value("game", "is_aim_toggle_gpad"))
	run_toggle_gpad_check_button.set_pressed_no_signal(Settings.config_file.get_value("game", "is_run_toggle_gpad"))
	posture_switch_toggle_km_check_button.set_pressed_no_signal(Settings.config_file.get_value("game", "is_posture_switch_toggle_km"))
	aim_smooth_check_button.set_pressed_no_signal(Settings.config_file.get_value("game", "is_aim_smooth"))
	movement_smooth_check_button.set_pressed_no_signal(Settings.config_file.get_value("game", "is_movement_smooth"))


func _on_game_slider_changed(value: float, key: String) -> void:
	Settings.config_file.set_value("game", key, value)
	Settings.save_settings()


func _on_inverted_toggled(toggled_on: bool) -> void:
	Settings.config_file.set_value("game", "is_inverted", toggled_on)
	Settings.save_settings()


func _on_game_toggle_changed(toggled_on: bool, key: String) -> void:
	Settings.config_file.set_value("game", key, toggled_on)
	Settings.save_settings()
