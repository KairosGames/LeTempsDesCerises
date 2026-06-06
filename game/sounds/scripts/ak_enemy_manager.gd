extends Node3D

@export var versaillais : CharacterBody3D
@export var shoot : AkEvent3D
@export var steps : AkEvent3D
@export var label : Label3D
@export var barks_parent : Node3D

var is_barking : bool = false
var delay : float = 1
var delay_offset : float = 1

func _enter_tree() -> void:
	Wwise.set_switch("Character_Type", String("Type" + str(randi_range(1, 3))), self)
	WwiseGlobal.register(self, "enemy")
	label.text = ""

func _ready() -> void:
	var random = String("Type" + str(randi_range(1, 3)))
	for i in barks_parent.get_children():
		Wwise.set_switch("Character_Type", random, i)

func _on_versaillais_shoot() -> void:
	shoot.post_event()

func _on_versaillais_move_start() -> void:
	steps.post_event()

func _on_versaillais_move_end() -> void:
	steps.stop_event()

func _on_versaillais_died() -> void:
	WwiseGlobal.remove(self)

func _on_ak_event_3d_audio_marker(data: Dictionary) -> void:
	var text : String = data.get("strLabel")
	text = text.replace("Ã©", "é")
	text = text.replace("Ã¨", "è")
	text = text.replace("Ã¹", "ù")
	text = text.replace("Ã", "à")
	text = text.replace("à´", "ô")
	text = text.replace("à§", "ç")
	text = text.replace(" ", "")
	label.text = text
