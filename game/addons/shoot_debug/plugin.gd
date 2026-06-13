@tool
extends EditorPlugin

const AUTOLOAD_NAME: String = "ShootDebug"
const AUTOLOAD_PATH: String = "res://addons/shoot_debug/shoot_debug.gd"

const SETTING_NAME: String = "addons/shoot_debug/enabled"
const SETTING_DEFAULT: bool = false

var _button: CheckButton

func _enter_tree() -> void:
	if not ProjectSettings.has_setting(SETTING_NAME):
		ProjectSettings.set_setting(SETTING_NAME, SETTING_DEFAULT)
	ProjectSettings.set_initial_value(SETTING_NAME, SETTING_DEFAULT)

	_button = CheckButton.new()
	_button.icon = preload("gun.svg")
	_button.button_pressed = ProjectSettings.get_setting(SETTING_NAME)
	_button.toggled.connect(_on_toggled)
	add_control_to_container(EditorPlugin.CONTAINER_TOOLBAR, _button)

	add_autoload_singleton(AUTOLOAD_NAME, AUTOLOAD_PATH)

	ProjectSettings.settings_changed.connect(_on_project_settings_changed)

func _exit_tree() -> void:
	ProjectSettings.settings_changed.disconnect(_on_project_settings_changed)

	remove_autoload_singleton(AUTOLOAD_NAME)

	remove_control_from_container(EditorPlugin.CONTAINER_TOOLBAR, _button)

	ProjectSettings.set_setting(SETTING_NAME, null)

func _on_toggled(toggled_on: bool) -> void:
	ProjectSettings.set_setting(SETTING_NAME, toggled_on)
	ProjectSettings.save()

func _on_project_settings_changed() -> void:
	_button.set_pressed_no_signal(ProjectSettings.get_setting(SETTING_NAME))
