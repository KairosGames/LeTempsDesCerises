extends Node

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
	config_file.load(CONFIG_FILE_PATH)
	for section: String in DEFAULTS:
		for key: String in DEFAULTS[section]:
			if not config_file.has_section_key(section, key):
				config_file.set_value(section, key, DEFAULTS[section][key])


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


func apply_graphics_settings(window: Window, environment: Environment, scene_root: Node) -> void:
	get_window().mode = Settings.config_file.get_value("video", "display_mode")
	DisplayServer.window_set_vsync_mode(Settings.config_file.get_value("video", "vsync") as DisplayServer.VSyncMode)
	Engine.max_fps = Settings.config_file.get_value("video", "max_fps")
	window.scaling_3d_scale = Settings.config_file.get_value("video", "resolution_scale")
	window.scaling_3d_mode = Settings.config_file.get_value("video", "scale_filter")
	window.use_taa = Settings.config_file.get_value("rendering", "taa")
	window.msaa_3d = Settings.config_file.get_value("rendering", "msaa")
	window.screen_space_aa = Viewport.SCREEN_SPACE_AA_FXAA if Settings.config_file.get_value("rendering", "fxaa") else Viewport.SCREEN_SPACE_AA_DISABLED

	if not Settings.config_file.get_value("rendering", "shadow_mapping"):
		# Disable shadows for all lights present during level load,
		# reducing the number of draw calls significantly.
		# FIXME: In the main menu, shadows aren't enabled again after enabling shadows
		# if they were previously disabled. We can't enable shadows on all lights unconditionally,
		# as this would negatively affect the level's performance.
		scene_root.propagate_call("set", ["shadow_enabled", false])

	match Settings.config_file.get_value("rendering", "ssao_quality"):
		-1:
			environment.ssao_enabled = false
		RenderingServer.ENV_SSAO_QUALITY_MEDIUM:
			environment.ssao_enabled = true
			RenderingServer.environment_set_ssao_quality(RenderingServer.ENV_SSAO_QUALITY_HIGH, false, 0.5, 2, 50, 300)
		_:
			environment.ssao_enabled = true
			RenderingServer.environment_set_ssao_quality(RenderingServer.ENV_SSAO_QUALITY_MEDIUM, true, 0.5, 2, 50, 300)

	match Settings.config_file.get_value("rendering", "ssil_quality"):
		1:
			environment.ssil_enabled = false
		RenderingServer.ENV_SSIL_QUALITY_MEDIUM:
			environment.ssil_enabled = true
			RenderingServer.environment_set_ssil_quality(RenderingServer.ENV_SSIL_QUALITY_MEDIUM, false, 0.5, 2, 50, 300)
		_:
			environment.ssil_enabled = true
			RenderingServer.environment_set_ssil_quality(RenderingServer.ENV_SSIL_QUALITY_HIGH, true, 0.5, 2, 50, 300)

	environment.glow_enabled = Settings.config_file.get_value("rendering", "bloom")
	environment.volumetric_fog_enabled = Settings.config_file.get_value("rendering", "volumetric_fog")
