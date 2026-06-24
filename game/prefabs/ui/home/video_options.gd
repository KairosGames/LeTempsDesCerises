extends VBoxContainer

const DISPLAY_MODE_LABELS: Array[String] = ["Window", "Fullscreen", "Exclusive Fullscreen"]
const DISPLAY_MODE_VALUES: Array[int] = [
	Window.MODE_WINDOWED,
	Window.MODE_FULLSCREEN,
	Window.MODE_EXCLUSIVE_FULLSCREEN,
]

const VSYNC_LABELS: Array[String] = ["Disabled", "Enabled", "Adaptive", "Mailbox"]
const VSYNC_VALUES: Array[int] = [
	DisplayServer.VSYNC_DISABLED,
	DisplayServer.VSYNC_ENABLED,
	DisplayServer.VSYNC_ADAPTIVE,
	DisplayServer.VSYNC_MAILBOX,
]

const MAX_FPS_LABELS: Array[String] = ["30", "40", "60", "72", "90", "120", "144", "Unlimited"]
const MAX_FPS_VALUES: Array[int] = [30, 40, 60, 72, 90, 120, 144, 0]

const RESOLUTION_SCALE_LABELS: Array[String] = [
	"Ultra Performance",
	"Performance",
	"Balanced",
	"Quality",
	"Ultra Quality",
	"Native",
]
const RESOLUTION_SCALE_VALUES: Array[float] = [1.0 / 3.0, 1.0 / 2.0, 1.0 / 1.7, 1.0 / 1.5, 1.0 / 1.3, 1.0]

const SCALE_FILTER_LABELS: Array[String] = [
	"Bilinear",
	"AMD FSR 1.0",
	"MetalFX Spatial",
	"AMD FSR 2.2",
	"MetalFX Temporal",
]
const SCALE_FILTER_VALUES: Array[int] = [
	Viewport.SCALING_3D_MODE_BILINEAR,
	Viewport.SCALING_3D_MODE_FSR,
	Viewport.SCALING_3D_MODE_METALFX_SPATIAL,
	Viewport.SCALING_3D_MODE_FSR2,
	Viewport.SCALING_3D_MODE_METALFX_TEMPORAL,
]

const BOOLEAN_LABELS: Array[String] = ["Disabled", "Enabled"]
const BOOLEAN_VALUES: Array[bool] = [false, true]

const MSAA_LABELS: Array[String] = ["Disabled", "2×", "4×", "8×"]
const MSAA_VALUES: Array[int] = [
	Viewport.MSAA_DISABLED,
	Viewport.MSAA_2X,
	Viewport.MSAA_4X,
	Viewport.MSAA_8X,
]

const AO_LABELS: Array[String] = ["Disabled", "Medium", "High"]
const SSAO_VALUES: Array[int] = [-1, RenderingServer.ENV_SSAO_QUALITY_MEDIUM, RenderingServer.ENV_SSAO_QUALITY_HIGH]
const SSIL_VALUES: Array[int] = [-1, RenderingServer.ENV_SSIL_QUALITY_MEDIUM, RenderingServer.ENV_SSIL_QUALITY_HIGH]

const ROWS: Dictionary = {
	"DisplayMode": {
		"section": "video",
		"key": "display_mode",
		"labels": DISPLAY_MODE_LABELS,
		"values": DISPLAY_MODE_VALUES,
		"label_path": ^"Settings/DisplayMode/Fullscreen",
		"previous_path": ^"Settings/DisplayMode/Windowed",
		"next_path": ^"Settings/DisplayMode/ExclusiveFullscreen",
	},
	"VSync": {
		"section": "video",
		"key": "vsync",
		"labels": VSYNC_LABELS,
		"values": VSYNC_VALUES,
		"label_path": ^"Settings/VSync/Enabled",
		"previous_path": ^"Settings/VSync/Disabled",
		"next_path": ^"Settings/VSync/Adaptive",
	},
	"MaxFPS": {
		"section": "video",
		"key": "max_fps",
		"labels": MAX_FPS_LABELS,
		"values": MAX_FPS_VALUES,
		"label_path": ^"Settings/MaxFPS/Value",
		"previous_path": ^"Settings/MaxFPS/Previous",
		"next_path": ^"Settings/MaxFPS/Next",
	},
	"ResolutionScale": {
		"section": "video",
		"key": "resolution_scale",
		"labels": RESOLUTION_SCALE_LABELS,
		"values": RESOLUTION_SCALE_VALUES,
		"label_path": ^"Settings/ResolutionScale/Value",
		"previous_path": ^"Settings/ResolutionScale/Previous",
		"next_path": ^"Settings/ResolutionScale/Next",
	},
	"ScaleFilter": {
		"section": "video",
		"key": "scale_filter",
		"labels": SCALE_FILTER_LABELS,
		"values": SCALE_FILTER_VALUES,
		"label_path": ^"Settings/ScaleFilter/Value",
		"previous_path": ^"Settings/ScaleFilter/Previous",
		"next_path": ^"Settings/ScaleFilter/Next",
	},
	"TAA": {
		"section": "rendering",
		"key": "taa",
		"labels": BOOLEAN_LABELS,
		"values": BOOLEAN_VALUES,
		"label_path": ^"Settings/TAA/Value",
		"previous_path": ^"Settings/TAA/Previous",
		"next_path": ^"Settings/TAA/Next",
	},
	"MSAA": {
		"section": "rendering",
		"key": "msaa",
		"labels": MSAA_LABELS,
		"values": MSAA_VALUES,
		"label_path": ^"Settings/MSAA/Value",
		"previous_path": ^"Settings/MSAA/Previous",
		"next_path": ^"Settings/MSAA/Next",
	},
	"FXAA": {
		"section": "rendering",
		"key": "fxaa",
		"labels": BOOLEAN_LABELS,
		"values": BOOLEAN_VALUES,
		"label_path": ^"Settings/FXAA/Value",
		"previous_path": ^"Settings/FXAA/Previous",
		"next_path": ^"Settings/FXAA/Next",
	},
	"SSAO": {
		"section": "rendering",
		"key": "ssao_quality",
		"labels": AO_LABELS,
		"values": SSAO_VALUES,
		"label_path": ^"Settings/SSAO/Value",
		"previous_path": ^"Settings/SSAO/Previous",
		"next_path": ^"Settings/SSAO/Next",
	},
	"SSIL": {
		"section": "rendering",
		"key": "ssil_quality",
		"labels": AO_LABELS,
		"values": SSIL_VALUES,
		"label_path": ^"Settings/SSIL/Value",
		"previous_path": ^"Settings/SSIL/Previous",
		"next_path": ^"Settings/SSIL/Next",
	},
}

@onready var apply_button: Button = get_node(^"Actions/Apply")
@onready var cancel_button: Button = get_node(^"Actions/Cancel")

var _applied_indices: Dictionary = {}
var _pending_indices: Dictionary = {}


func _ready() -> void:
	_connect_row_buttons()
	apply_button.pressed.connect(_on_apply_pressed)
	cancel_button.pressed.connect(_on_cancel_pressed)
	load_video_settings()


func load_video_settings() -> void:
	_applied_indices.clear()
	_pending_indices.clear()

	for row_name_variant: Variant in ROWS.keys():
		var row_name: String = row_name_variant as String
		var row: Dictionary = ROWS[row_name] as Dictionary
		var value: Variant = _get_row_setting_value(row_name, row)
		var index: int = _find_row_index(row, value)
		_applied_indices[row_name] = index
		_pending_indices[row_name] = index

	_apply_pending_state()


func _connect_row_buttons() -> void:
	for row_name_variant: Variant in ROWS.keys():
		var row_name: String = row_name_variant as String
		var row: Dictionary = ROWS[row_name] as Dictionary
		var previous_button: Button = get_node(row["previous_path"] as NodePath)
		var next_button: Button = get_node(row["next_path"] as NodePath)
		previous_button.pressed.connect(_on_step_pressed.bind(row_name, -1))
		next_button.pressed.connect(_on_step_pressed.bind(row_name, 1))


func _on_step_pressed(row_name: String, direction: int) -> void:
	var row: Dictionary = ROWS[row_name] as Dictionary
	var labels: Array[String] = row["labels"] as Array[String]
	var current_index: int = _pending_indices.get(row_name, 0) as int
	var next_index: int = wrapi(current_index + direction, 0, labels.size())
	_pending_indices[row_name] = next_index
	_apply_pending_state()


func _apply_pending_state() -> void:
	for row_name_variant: Variant in ROWS.keys():
		var row_name: String = row_name_variant as String
		var row: Dictionary = ROWS[row_name] as Dictionary
		var label: Label = get_node(row["label_path"] as NodePath)
		var labels: Array[String] = row["labels"] as Array[String]
		var current_index: int = _pending_indices.get(row_name, 0) as int
		label.text = labels[current_index]


func _on_apply_pressed() -> void:
	for row_name_variant: Variant in ROWS.keys():
		var row_name: String = row_name_variant as String
		var row: Dictionary = ROWS[row_name] as Dictionary
		var index: int = _pending_indices.get(row_name, 0) as int
		var values: Array = row["values"] as Array
		Settings.config_file.set_value(row["section"] as String, row["key"] as String, values[index])

	_apply_window_video_settings()
	Settings.save_settings()
	_applied_indices = _pending_indices.duplicate(true)


func _on_cancel_pressed() -> void:
	_pending_indices = _applied_indices.duplicate(true)
	_apply_pending_state()


func _apply_window_video_settings() -> void:
	var window: Window = get_window()
	var display_mode: int = Settings.config_file.get_value("video", "display_mode")
	var vsync_mode: DisplayServer.VSyncMode = Settings.config_file.get_value("video", "vsync") as DisplayServer.VSyncMode
	var max_fps: int = Settings.config_file.get_value("video", "max_fps")
	var resolution_scale: float = Settings.config_file.get_value("video", "resolution_scale")
	var scale_filter: int = Settings.get_video_scale_filter()
	var taa_enabled: bool = Settings.config_file.get_value("rendering", "taa")
	var msaa: Viewport.MSAA = Settings.config_file.get_value("rendering", "msaa") as Viewport.MSAA
	var fxaa_enabled: bool = Settings.config_file.get_value("rendering", "fxaa")

	window.mode = display_mode as Window.Mode
	DisplayServer.window_set_vsync_mode(vsync_mode)
	Engine.max_fps = max_fps
	window.scaling_3d_scale = resolution_scale
	window.scaling_3d_mode = scale_filter as Viewport.Scaling3DMode
	window.use_taa = taa_enabled
	window.msaa_3d = msaa
	window.screen_space_aa = Viewport.SCREEN_SPACE_AA_FXAA if fxaa_enabled else Viewport.SCREEN_SPACE_AA_DISABLED


func _get_row_setting_value(row_name: String, row: Dictionary) -> Variant:
	if row_name == "ScaleFilter":
		return Settings.get_video_scale_filter()
	return Settings.config_file.get_value(row["section"] as String, row["key"] as String)


func _find_row_index(row: Dictionary, value: Variant) -> int:
	var values: Array = row["values"] as Array
	for index: int in values.size():
		var candidate: Variant = values[index]
		if candidate is float and value is float:
			if is_equal_approx(candidate as float, value as float):
				return index
		elif candidate == value:
			return index

	if row["key"] == "scale_filter":
		return SCALE_FILTER_VALUES.find(Viewport.SCALING_3D_MODE_FSR2)
	return 0
