extends Node3D

@export var communard : Node3D
@export var shoot : AkEvent3D
@export var steps : AkEvent3D
@export var label : Label3D
@export var barks_parent : Node3D
@export var debug_text : bool 

var is_barking : bool = false
var barks : Dictionary[String, int]
var gender : gender_type = gender_type.FEMALE
var rand_array = [1, 2, 4, 5, 6]

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
	#match gender:
		#gender_type.MALE:
			#var random = String("Type" + str(randi_range(1, 3)))
			#for i in barks_parent.get_children():
				#Wwise.set_switch("Character_Type", random, i)
		#gender_type.FEMALE:
			#var random = String("Type" + str(randi_range(1, 3)))
			#for i in barks_parent.get_children():
				#Wwise.set_switch("Character_Type", random, i)
	var random : String = str("Type" + str(rand_array.pick_random()))
	for i in barks_parent.get_children():
		Wwise.set_switch("Character_Type", random, i)
	if WwiseGlobal.allow_barks:
		trigg_bark()


func post_event(event: String, delay: float):
	if is_barking : return
	is_barking = true
	await get_tree().create_timer(delay).timeout
	barks_parent.get_child(barks.get(event)).post_event()


func _on_communard_shoot() -> void:
	shoot.post_event()

func _on_communard_died() -> void:
	WwiseGlobal.remove(self)
	#Wwise.stop_all(self)


func set_text(data: Dictionary): 
	if not debug_text: return
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

func trigg_bark():
	return
	if !is_barking:
		post_event("Barricade_State", randf_range(1, 2))
	await get_tree().create_timer(1).timeout
	trigg_bark()


func _on_communard_dying() -> void:
	for event : AkEvent3D in barks_parent.get_children() :
		event.stop_event()
	post_event("Voice_Cancel", 0)
	WwiseGlobal.remove(self)
