extends Node3D

@export var communard : Node3D
@export var shoot : AkEvent3D
@export var steps : AkEvent3D
@export var label : Label3D
@export var barks_parent : Node3D

var is_barking : bool = false
var barks : Dictionary[String, int]
var gender : gender_type = gender_type.FEMALE

enum gender_type {
	MALE,
	FEMALE
}

func _enter_tree() -> void:
	WwiseGlobal.register(self, "ally")
	label.text = ""
	for i : AkEvent3D in barks_parent.get_children():
		barks[i.name] = i.get_index()
		i.end_of_event.connect(reset_text)
		i.audio_marker.connect(set_text)

func _ready() -> void:
	print(gender)
	match gender:
		gender_type.MALE:
			var random = String("Type" + str(randi_range(1, 3)))
			for i in barks_parent.get_children():
				Wwise.set_switch("Character_Type", random, i)
		gender_type.FEMALE:
			var random = String("Type" + str(randi_range(1, 3)))
			for i in barks_parent.get_children():
				Wwise.set_switch("Character_Type", random, i)

func post_event(event : String, delay : int):
	is_barking = true
	await get_tree().create_timer(delay).timeout
	barks_parent.get_child(barks.get(event)).post_event()
	print(event)

func _on_communard_shoot() -> void:
	shoot.post_event()

func _on_communard_died() -> void:
	WwiseGlobal.remove(self)
	Wwise.stop_all(self)

func set_text(data: Dictionary): 
	var text : String = data.get("strLabel")
	text = text.replace("Ã©", "é")
	text = text.replace("Ã¨", "è")
	text = text.replace("Ã¹", "ù")
	text = text.replace("Ã", "à")
	text = text.replace(" ", "")
	label.text = text
	print(text)

func reset_text(_data):
	print("reset")
	label.text = ""
	is_barking = false
