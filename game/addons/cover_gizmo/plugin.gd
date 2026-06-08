@tool
extends EditorPlugin

var _button: CheckButton

func _enter_tree() -> void:
	_button = CheckButton.new()
	_button.icon = preload("uid://r7ntbqc18umi")
	_button.button_pressed = CoverGizmo.is_enabled
	_button.toggled.connect(_on_toggled)
	add_control_to_container(EditorPlugin.CONTAINER_TOOLBAR, _button)

func _exit_tree() -> void:
	remove_control_from_container(EditorPlugin.CONTAINER_TOOLBAR, _button)

func _on_toggled(toggle_on: bool) -> void:
	CoverGizmo.is_enabled = toggle_on
	if toggle_on: CoverGizmo.show.emit()
	else: CoverGizmo.hide.emit()
