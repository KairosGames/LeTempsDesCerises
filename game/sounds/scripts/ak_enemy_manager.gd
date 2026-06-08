extends Node3D

@export var versaillais : CharacterBody3D
@export var shoot : AkEvent3D
@export var steps : AkEvent3D
@export var label : Label3D
@export var barks_parent : Node3D

var is_barking : bool = false
var barks : Dictionary[String, int]
var delay : float = 1
var delay_offset : float = 1

func _ready() -> void:
	WwiseGlobal.register(self, "enemy")
	label.text = ""
	for i : AkEvent3D in barks_parent.get_children():
		barks[i.name] = i.get_index()
		i.end_of_event.connect(reset_text)
		i.audio_marker.connect(set_text)
		Wwise.set_switch("Character_Type", String("Type" + str(randi_range(1, 3))), i)

func _on_versaillais_shoot() -> void:
	shoot.post_event()

func _on_versaillais_move_start() -> void:
	steps.post_event()

func _on_versaillais_move_end() -> void:
	steps.stop_event()

func _on_versaillais_died() -> void:
	WwiseGlobal.remove(self)

func set_text(data: Dictionary): 
	var text : String = data.get("strLabel")
	text = text.replace("Ã©", "é")
	text = text.replace("Ã¨", "è")
	text = text.replace("Ã¹", "ù")
	text = text.replace("Ã", "à")
	text = text.replace("à´", "ô")
	text = text.replace("à§", "ç")
	text = text.replace(" ", "")
	label.text = text

func reset_text(_data):
	label.text = ""
	is_barking = false

func post_event(event : String, event_delay : int):
	if is_barking : return
	is_barking = true
	await get_tree().create_timer(event_delay).timeout
	barks_parent.get_child(barks.get(event)).post_event()

func trigg_bark():
	if !is_barking:
		post_event("Barricade_State", 0)
	await get_tree().create_timer(randf_range(1, 5)).timeout
	trigg_bark()
