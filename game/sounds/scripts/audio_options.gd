extends VBoxContainer


@onready var master_slider: HSlider = $MasterVolume/Slider
@onready var music_slider: HSlider = $MusicVolume/Slider
@onready var effect_slider: HSlider = $EffectVolume/Slider
@onready var voice_slider: HSlider = $VoiceVolume/Slider
@onready var reset_button: Button = $Actions/Reset


func _ready() -> void:
	_load_audio_settings()
	reset_button.pressed.connect(_on_reset_pressed)


func _on_music_slider_value_changed(value: float) -> void:
	Wwise.set_rtpc_value("MSC", value, null)
	Settings.config_file.set_value("audio", "music", value)
	Settings.save_settings()

func _on_master_slider_value_changed(value: float) -> void:
	Wwise.set_rtpc_value("Master", value, null)
	Settings.config_file.set_value("audio", "master", value)
	Settings.save_settings()

func _on_effect_slider_value_changed(value: float) -> void:
	Wwise.set_rtpc_value("SFX", value, null)
	Settings.config_file.set_value("audio", "effect", value)
	Settings.save_settings()

func _on_voice_slider_value_changed(value: float) -> void:
	Wwise.set_rtpc_value("VX", value, null)
	Settings.config_file.set_value("audio", "voice", value)
	Settings.save_settings()


func _load_audio_settings() -> void:
	var master_value: float = Settings.config_file.get_value("audio", "master")
	var music_value: float = Settings.config_file.get_value("audio", "music")
	var effect_value: float = Settings.config_file.get_value("audio", "effect")
	var voice_value: float = Settings.config_file.get_value("audio", "voice")
	_apply_audio_values(master_value, music_value, effect_value, voice_value, false)


func _on_reset_pressed() -> void:
	var audio_defaults: Dictionary = Settings.DEFAULTS["audio"]
	var master_value: float = audio_defaults["master"] as float
	var music_value: float = audio_defaults["music"] as float
	var effect_value: float = audio_defaults["effect"] as float
	var voice_value: float = audio_defaults["voice"] as float
	_apply_audio_values(master_value, music_value, effect_value, voice_value, true)
	reset_button.grab_focus()


func _apply_audio_values(master_value: float, music_value: float, effect_value: float, voice_value: float, persist: bool) -> void:
	master_slider.set_value_no_signal(master_value)
	music_slider.set_value_no_signal(music_value)
	effect_slider.set_value_no_signal(effect_value)
	voice_slider.set_value_no_signal(voice_value)
	Wwise.set_rtpc_value("Master", master_value, null)
	Wwise.set_rtpc_value("MSC", music_value, null)
	Wwise.set_rtpc_value("SFX", effect_value, null)
	Wwise.set_rtpc_value("VX", voice_value, null)
	if persist:
		Settings.config_file.set_value("audio", "master", master_value)
		Settings.config_file.set_value("audio", "music", music_value)
		Settings.config_file.set_value("audio", "effect", effect_value)
		Settings.config_file.set_value("audio", "voice", voice_value)
		Settings.save_settings()
