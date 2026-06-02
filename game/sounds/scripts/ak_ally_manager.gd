extends Node3D

@export var communard : Node3D
@export var shoot : AkEvent3D
@export var steps : AkEvent3D
@export var bark : AkEvent3D
@export var ally_dead : AkEvent3D
@export var enemy_dead : AkEvent3D
@export var coward : AkEvent3D
@export var label : Label3D

var is_barking : bool = false
var is_feedbarking : bool = false
var delay : float

func _enter_tree() -> void:
	WwiseGlobal.register(self, "ally")
	label.text = ""
	await get_tree().create_timer(randf_range(0, 10)).timeout
	trigg_bark()
	ally_dead.end_of_event.connect(reset_text)
	enemy_dead.end_of_event.connect(reset_text)
	coward.end_of_event.connect(reset_text)

func _on_communard_shoot() -> void:
	shoot.post_event()

func _on_communard_died() -> void:
	WwiseGlobal.remove(self)
	bark.stop_event()

func trigg_bark():
	if !WwiseGlobal.allow_barks : return
	await get_tree().create_timer(randf_range(delay, delay * 2)).timeout
	if !is_barking and !is_feedbarking :
		bark.post_event()
		is_barking = true
	trigg_bark()

func set_text(data: Dictionary, is_feedback : bool): 
	if is_feedbarking and !is_feedback: 
		return
	var text : String = data.get("strLabel")
	text = text.replace("Ã©", "é")
	text = text.replace("Ã¨", "è")
	text = text.replace("Ã¹", "ù")
	text = text.replace("Ã", "à")
	text = text.replace(" ", "")
	label.text = text

func _on_bark_audio_marker(data: Dictionary) -> void:
	set_text(data, false)

func _on_bark_end_of_event(_data: Dictionary) -> void:
	label.text = ""
	is_barking = false

func reset_text(_data):
	print("reset")
	label.text = ""
	is_feedbarking = false

func _on_bark_duration(data: Dictionary) -> void:
	delay = data.get("fDuration") / 1000 * 5

func _on_enemy_dead_audio_marker(data: Dictionary) -> void:
	set_text(data, true)
	is_feedbarking = true

func _on_ally_dead_audio_marker(data: Dictionary) -> void:
	set_text(data, true)
	is_feedbarking = true

func _on_coward_audio_marker(data: Dictionary) -> void:
	if !WwiseGlobal.allow_barks : return
	set_text(data, true)
	is_feedbarking = true
