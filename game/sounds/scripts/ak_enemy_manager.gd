extends Node3D

@export var versaillais : CharacterBody3D
@export var shoot : AkEvent3D
@export var steps : AkEvent3D
@export var bark : AkEvent3D
@export var label : Label3D

var is_barking : bool = false
var delay : float
var delay_offset : float = 1

func _enter_tree() -> void:
	BarksManager.register(self, "enemy")
	label.text = ""
	trigg_bark()

func _on_versaillais_shoot() -> void:
	shoot.post_event()

func _on_versaillais_move_start() -> void:
	steps.post_event()

func _on_versaillais_move_end() -> void:
	steps.stop_event()

func _on_versaillais_died() -> void:
	BarksManager.remove(self)
	bark.stop_event()

func trigg_bark():
	await get_tree().create_timer(randf_range(delay, delay * 2)).timeout
	if !is_barking :
		bark.post_event()
		is_barking = true
	trigg_bark()

func _on_ak_event_3d_audio_marker(data: Dictionary) -> void:
	var text : String = data.get("strLabel")
	text = text.replace("Ã©", "é")
	text = text.replace("Ã¨", "è")
	text = text.replace("Ã¹", "ù")
	text = text.replace("Ã", "à")
	text = text.replace(" ", "")
	label.text = text


func _on_bark_end_of_event(data: Dictionary) -> void:
	label.text = ""
	is_barking = false


func _on_bark_duration(data: Dictionary) -> void:
	delay = data.get("fDuration") / 1000 * 3
