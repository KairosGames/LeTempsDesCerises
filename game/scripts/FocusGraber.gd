class_name FocusGraber extends Control

@export var control: Control

func _ready() -> void:
	visibility_changed.connect(_on_visiblity_changed)

func _on_visiblity_changed() -> void:
	if is_visible_in_tree(): control.grab_focus()
