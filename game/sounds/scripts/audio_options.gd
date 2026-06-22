extends VBoxContainer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_music_slider_value_changed(value: float) -> void:
	Wwise.set_rtpc_value("MSC", value, null)

func _on_master_slider_value_changed(value: float) -> void:
	Wwise.set_rtpc_value("Master", value, null)

func _on_effect_slider_value_changed(value: float) -> void:
	Wwise.set_rtpc_value("SFX", value, null)

func _on_voice_slider_value_changed(value: float) -> void:
	Wwise.set_rtpc_value("VX", value, null)
