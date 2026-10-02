class_name PlatformVisibility extends Control

@export_flags("Desktop:1", "Console:2", "All:3") var platform: int = Inputs.Platform.All

@onready var _parent: Control = get_parent_control()

func _ready() -> void:
	if not _parent: return
	Inputs.platform_changed.connect(_on_platform_changed)
	_on_platform_changed(Inputs.current_platform)

func _on_platform_changed(new_platform: Inputs.Platform) -> void:
	_parent.visible = new_platform & platform != 0
