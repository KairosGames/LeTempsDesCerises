extends Node3D

@export var dialogue_event : AkEvent3D
@export var label : Label3D

var npc_name : String
var text_duration : float
var text_speed : float

func _ready() -> void:
	npc_name = get_parent().name
	WwiseGlobal.narrators.append(self)
	Wwise.set_switch("Character", npc_name, dialogue_event)
	await get_tree().create_timer(1).timeout
	WwiseGlobal.player.add_line(npc_name)
	Wwise.load_bank(npc_name)

func voiceline():
	dialogue_event.post_event()

func _on_dialogue_end_of_event(_data: Dictionary) -> void:
	WwiseGlobal.line_ended()
	label.text = ""
	WwiseGlobal.player.update_line(npc_name, "")

func _on_dialogue_audio_marker(data: Dictionary) -> void:
	var text : String = data.get("strLabel")
	text = text.replace("Ã©", "é")
	text = text.replace("Ã¨", "è")
	text = text.replace("Ã¹", "ù")
	text = text.replace("Ã", "à")
	text = text.replace("à´", "ô")
	text = text.replace("à§", "ç")
	text = text.replace("à¢", "â")
	text = text.replace("àª", "ê")
	text = text.replace(" ", "")
	label.text = ""
	WwiseGlobal.player.update_line(npc_name,text)
	for i in text.length():
		label.text = label.text + text[i]
		await get_tree().create_timer(randf_range(0.01, 0.03)).timeout

func _on_tree_exited() -> void:
	WwiseGlobal.unload(npc_name)


func _on_dialogue_duration(data: Dictionary) -> void:
	text_duration = data.get("fDuration") / 2
