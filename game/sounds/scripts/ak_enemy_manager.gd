extends Node3D

@export var versaillais : Node3D
@export var shoot : AkEvent3D
@export var steps : AkEvent3D
@export var bark : AkEvent3D
@export var label : Label3D

var is_barking : bool = false

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

func _on_communard_shoot() -> void:
	shoot.post_event()

func _on_versaillais_died(agent: Agent) -> void:
	BarksManager.remove(self)

func trigg_bark():
	await get_tree().create_timer(0.5).timeout
	if !is_barking :
		bark.post_event()
		is_barking = true
	trigg_bark()



func _on_ak_event_3d_audio_marker(data: Dictionary) -> void:
	var text : String = data.get("strLabel")
	text = text.replace("Ã", "à")
	label.text = text


func _on_bark_end_of_event(data: Dictionary) -> void:
	label.text = ""
	is_barking = false
