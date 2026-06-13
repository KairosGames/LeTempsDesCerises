@tool
extends EditorPlugin

var _button: CheckButton

const SETTING_NAME: String = "addons/cover_gizmo/enabled"
const SETTING_DEFAULT: bool = false

func _enter_tree() -> void:
	if not ProjectSettings.has_setting(SETTING_NAME):
		ProjectSettings.set_setting(SETTING_NAME, SETTING_DEFAULT)
	ProjectSettings.set_initial_value(SETTING_NAME, SETTING_DEFAULT)

	_button = CheckButton.new()
	_button.icon = preload("target.svg")
	_button.button_pressed = ProjectSettings.get_setting(SETTING_NAME)
	_button.toggled.connect(_on_toggled)
	add_control_to_container(EditorPlugin.CONTAINER_TOOLBAR, _button)

	ProjectSettings.settings_changed.connect(_on_project_settings_changed)

func _exit_tree() -> void:
	ProjectSettings.settings_changed.disconnect(_on_project_settings_changed)
	remove_control_from_container(EditorPlugin.CONTAINER_TOOLBAR, _button)
	ProjectSettings.set_setting(SETTING_NAME, null)

func _on_toggled(toggle_on: bool) -> void:
	ProjectSettings.set_setting(SETTING_NAME, toggle_on)
	ProjectSettings.save()

func _on_project_settings_changed() -> void:
	_button.set_pressed_no_signal(ProjectSettings.get_setting(SETTING_NAME))
