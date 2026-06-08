@tool
class_name CoverGizmo extends EditorPlugin

signal cover_show
signal cover_hide

static var instance: CoverGizmo = null
static var is_enabled: bool = false

var _button: CheckButton

func _enter_tree() -> void:
	instance = self
	_button = CheckButton.new()
	_button.icon = preload("uid://r7ntbqc18umi")
	_button.button_pressed = is_enabled
	_button.toggled.connect(_on_toggled)
	add_control_to_container(EditorPlugin.CONTAINER_TOOLBAR, _button)

func _exit_tree() -> void:
	remove_control_from_container(EditorPlugin.CONTAINER_TOOLBAR, _button)

func _on_toggled(toggle_on: bool) -> void:
	is_enabled = toggle_on
	if toggle_on: cover_show.emit()
	else: cover_hide.emit()
