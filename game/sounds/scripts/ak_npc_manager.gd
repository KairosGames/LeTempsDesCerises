extends Node3D

@export var dialogue_event : AkEvent3D
@export var label : Label3D
@export var debug_text: bool

var npc_name : String
var text_duration : float
var text_speed : float
var valid_names : Array[String] = ["Louise", "Marie", "Georges", "Jules", "Francois", "Michel", "Officier"]

func _ready() -> void:
	npc_name = get_parent().name
	get_parent().shot.connect(shoot_event)
	if not npc_name in valid_names: return
	label.text = npc_name
	WwiseGlobal.register_narrator(self)
	while not Wwise.is_initialized():
		await get_tree().process_frame
	Wwise.set_switch("Character", npc_name, dialogue_event)
	Wwise.load_bank(npc_name)
	await get_tree().process_frame
	WwiseGlobal.mark_narrator_ready(self)
	while not WwiseGlobal.player or not is_instance_valid(WwiseGlobal.player):
		await get_tree().process_frame
	WwiseGlobal.player.add_line(npc_name)

func voiceline():
	if not WwiseGlobal.is_narrator_ready(self): return
	dialogue_event.post_event()

func _on_dialogue_end_of_event(_data: Dictionary) -> void:
	WwiseGlobal.line_ended(npc_name)
	print(npc_name, " a fini")
	WwiseGlobal.player.call_deferred("update_line", npc_name, "")
	if !debug_text : return
	label.text = ""

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
	WwiseGlobal.player.update_line(npc_name,text)
	if not debug_text : return
	label.text = ""
	for i in text.length():
		label.text = label.text + text[i]
		await get_tree().create_timer(randf_range(0.01, 0.03)).timeout

func _on_dialogue_duration(data: Dictionary) -> void:
	WwiseGlobal.relevant_narrators += 1
	text_duration = data.get("fDuration")

func _on_tree_exiting() -> void:
	if npc_name in valid_names:
		WwiseGlobal.unload_npc(npc_name)

func shoot_event():
	Wwise.post_event("Npc_Shoot", self)
