extends Node

signal language_changed(language: String)

enum GIType {
	SDFGI = 0,
	VOXEL_GI = 1,
	LIGHTMAP_GI = 2,
}

enum GIQuality {
	DISABLED = 0,
	LOW = 1,
	HIGH = 2,
}

const CONFIG_FILE_PATH: String = "user://settings.ini"

var METAL_FX_SUPPORT: bool = RenderingServer.get_current_rendering_driver_name() == "metal"

var DEFAULTS: Dictionary = {
	"video" = {
		"display_mode": Window.MODE_EXCLUSIVE_FULLSCREEN,
		"vsync": DisplayServer.VSYNC_ENABLED,
		"max_fps": 0,
		"resolution_scale": 1.0,
		"scale_filter": Viewport.SCALING_3D_MODE_METALFX_TEMPORAL if METAL_FX_SUPPORT else Viewport.SCALING_3D_MODE_FSR2,
	},
	"rendering" = {
		"taa": false,
		"msaa": Viewport.MSAA_DISABLED,
		"fxaa": false,
		"shadow_mapping": true,
		"gi_type": GIType.VOXEL_GI,
		"gi_quality": GIQuality.LOW,
		"ssao_quality": RenderingServer.ENV_SSAO_QUALITY_MEDIUM,
		"ssil_quality": -1,  # Disabled
		"bloom": true,
		"volumetric_fog": true,
	},
	"audio" = {
		"master": 1.0,
		"music": 1.0,
		"effect": 1.0,
		"voice": 1.0,
	},
	"game" = {
		"language": "French(France)",
		"sensi_default": 7.0,
		"sensi_aiming": 7.0,
		"is_inverted": false,
		"h_sensi_multiplier": 1.0,
		"v_sensi_multiplier": 1.0,
		"l_jstick_threshold": 0.2,
		"r_jstick_threshold": 0.2,
		"is_aim_toggle_km": true,
		"is_run_toggle_km": false,
		"is_aim_toggle_gpad": false,
		"is_run_toggle_gpad": true,
		"is_posture_switch_toggle_km": true,
		"is_aim_smooth": true,
		"is_movement_smooth": true,
		"is_blood_enabled": true,
		"allow_subtitles": true,
	},
}

var config_file: ConfigFile = ConfigFile.new()


func _ready() -> void:
	load_settings()

func _input(input_event: InputEvent) -> void:
	if input_event.is_action_pressed(&"toggle_fullscreen"):
		get_window().mode = Window.MODE_EXCLUSIVE_FULLSCREEN if (!((get_window().mode == Window.MODE_EXCLUSIVE_FULLSCREEN) or (get_window().mode == Window.MODE_FULLSCREEN))) else Window.MODE_WINDOWED
		get_viewport().set_input_as_handled()


func load_settings() -> void:
	var load_result: Error = config_file.load(CONFIG_FILE_PATH)
	if load_result != OK and load_result != ERR_FILE_NOT_FOUND:
		push_warning("Failed to load settings file: %s" % error_string(load_result))

	for section: String in DEFAULTS:
		for key: String in DEFAULTS[section]:
			if not config_file.has_section_key(section, key):
				config_file.set_value(section, key, DEFAULTS[section][key])

	var scale_filter: int = get_video_scale_filter()
	if config_file.get_value("video", "scale_filter") != scale_filter:
		config_file.set_value("video", "scale_filter", scale_filter)

	WwiseGlobal.allow_subtitles = config_file.get_value("game", "allow_subtitles") == true


func get_language() -> String:
	var language_value: Variant = config_file.get_value("game", "language", DEFAULTS["game"]["language"])
	return str(language_value)


func set_language(language: String) -> void:
	if language == "" or get_language() == language: return
	config_file.set_value("game", "language", language)
	save_settings()
	language_changed.emit(language)


func save_settings() -> void:
	config_file.save(CONFIG_FILE_PATH)


func apply_game_settings(player_inputs: PlayerInputs) -> void:
	player_inputs.sensi_default = config_file.get_value("game", "sensi_default")
	player_inputs.sensi_aiming = config_file.get_value("game", "sensi_aiming")
	player_inputs.is_inverted = config_file.get_value("game", "is_inverted")
	player_inputs.h_sensi_multiplier = config_file.get_value("game", "h_sensi_multiplier")
	player_inputs.v_sensi_multiplier = config_file.get_value("game", "v_sensi_multiplier")
	player_inputs.l_jstick_threshold = config_file.get_value("game", "l_jstick_threshold")
	player_inputs.r_jstick_threshold = config_file.get_value("game", "r_jstick_threshold")


func apply_player_settings(player: Player) -> void:
	player.is_aim_toggle_km = config_file.get_value("game", "is_aim_toggle_km")
	player.is_run_toggle_km = config_file.get_value("game", "is_run_toggle_km")
	player.is_aim_toggle_gpad = config_file.get_value("game", "is_aim_toggle_gpad")
	player.is_run_toggle_gpad = config_file.get_value("game", "is_run_toggle_gpad")
	player.is_posture_switch_toggle_km = config_file.get_value("game", "is_posture_switch_toggle_km")
	player.is_aim_smooth = config_file.get_value("game", "is_aim_smooth")
	player.is_movement_smooth = config_file.get_value("game", "is_movement_smooth")


func get_video_scale_filter() -> int:
	var scale_filter: int = config_file.get_value("video", "scale_filter")
	if METAL_FX_SUPPORT:
		return scale_filter

	if (
		scale_filter == Viewport.SCALING_3D_MODE_METALFX_SPATIAL
		or scale_filter == Viewport.SCALING_3D_MODE_METALFX_TEMPORAL
	):
		return Viewport.SCALING_3D_MODE_FSR2

	return scale_filter


func apply_graphics_settings(window: Window, environment: Environment, scene_root: Node) -> void:
	var display_mode: int = config_file.get_value("video", "display_mode")
	var vsync_mode: DisplayServer.VSyncMode = config_file.get_value("video", "vsync") as DisplayServer.VSyncMode
	var max_fps: int = config_file.get_value("video", "max_fps")
	var resolution_scale: float = config_file.get_value("video", "resolution_scale")
	var scale_filter: int = get_video_scale_filter()
	var taa_enabled: bool = config_file.get_value("rendering", "taa")
	var msaa: Viewport.MSAA = config_file.get_value("rendering", "msaa") as Viewport.MSAA
	var fxaa_enabled: bool = config_file.get_value("rendering", "fxaa")

	get_window().mode = display_mode as Window.Mode
	DisplayServer.window_set_vsync_mode(vsync_mode)
	Engine.max_fps = max_fps
	window.scaling_3d_scale = resolution_scale
	window.scaling_3d_mode = scale_filter as Viewport.Scaling3DMode
	window.use_taa = taa_enabled
	window.msaa_3d = msaa
	window.screen_space_aa = Viewport.SCREEN_SPACE_AA_FXAA if fxaa_enabled else Viewport.SCREEN_SPACE_AA_DISABLED



	var shadow_mapping_enabled: bool = config_file.get_value("rendering", "shadow_mapping")
	var ssao_quality: int = config_file.get_value("rendering", "ssao_quality")
	var ssil_quality: int = config_file.get_value("rendering", "ssil_quality")
	var bloom_enabled: bool = config_file.get_value("rendering", "bloom")
	var volumetric_fog_enabled: bool = config_file.get_value("rendering", "volumetric_fog")

	if not shadow_mapping_enabled:
		# Disable shadows for all lights present during level load,
		# reducing the number of draw calls significantly.
		# FIXME: In the main menu, shadows aren't enabled again after enabling shadows
		# if they were previously disabled. We can't enable shadows on all lights unconditionally,
		# as this would negatively affect the level's performance.
		scene_root.propagate_call("set", ["shadow_enabled", false])

	match ssao_quality:
		-1:
			environment.ssao_enabled = false
		RenderingServer.ENV_SSAO_QUALITY_MEDIUM:
			environment.ssao_enabled = true
			RenderingServer.environment_set_ssao_quality(RenderingServer.ENV_SSAO_QUALITY_HIGH, false, 0.5, 2, 50, 300)
		_:
			environment.ssao_enabled = true
			RenderingServer.environment_set_ssao_quality(RenderingServer.ENV_SSAO_QUALITY_MEDIUM, true, 0.5, 2, 50, 300)

	match ssil_quality:
		-1:
			environment.ssil_enabled = false
		RenderingServer.ENV_SSIL_QUALITY_MEDIUM:
			environment.ssil_enabled = true
			RenderingServer.environment_set_ssil_quality(RenderingServer.ENV_SSIL_QUALITY_MEDIUM, false, 0.5, 2, 50, 300)
		_:
			environment.ssil_enabled = true
			RenderingServer.environment_set_ssil_quality(RenderingServer.ENV_SSIL_QUALITY_HIGH, true, 0.5, 2, 50, 300)

	environment.glow_enabled = bloom_enabled
	environment.volumetric_fog_enabled = volumetric_fog_enabled
