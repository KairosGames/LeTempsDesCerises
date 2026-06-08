@tool
extends EditorPlugin

var button: CheckButton
const AUTOLOAD_NAME: String = "ShootDebug"
const AUTOLOAD_PATH: String = "res://addons/shoot_debug/shoot_debug.gd"

const SETTING_NAME: String = "addons/shoot_debug/enabled"
const SETTING_DEFAULT: bool = false

func _enter_tree() -> void:
	if not ProjectSettings.has_setting(SETTING_NAME):
		ProjectSettings.set_setting(SETTING_NAME, SETTING_DEFAULT)
	ProjectSettings.set_initial_value(SETTING_NAME, SETTING_DEFAULT)
	ProjectSettings.set_as_internal(SETTING_NAME, true)
	
	button = CheckButton.new()
	button.icon = preload("gun.svg")
	button.button_pressed = ProjectSettings.get_setting(SETTING_NAME)
	button.toggled.connect(_on_toggled)
	add_control_to_container(EditorPlugin.CONTAINER_TOOLBAR, button)
	
	add_autoload_singleton(AUTOLOAD_NAME, AUTOLOAD_PATH)
	
	ProjectSettings.settings_changed.connect(_on_project_settings_changed)

func _exit_tree() -> void:
	ProjectSettings.settings_changed.disconnect(_on_project_settings_changed)
	
	remove_autoload_singleton(AUTOLOAD_NAME)
	
	remove_control_from_container(EditorPlugin.CONTAINER_TOOLBAR, button)
	
	ProjectSettings.set_setting(SETTING_NAME, null)

func _on_toggled(toggled_on: bool) -> void:
	ProjectSettings.set_setting(SETTING_NAME, toggled_on)
	ProjectSettings.save()

func _on_project_settings_changed() -> void:
	button.set_pressed_no_signal(ProjectSettings.get_setting(SETTING_NAME))
