extends Node3D

#@export var all_events : Array[AkEvent3D]

func _ready() -> void:
	GameManager.instance.all_states[2].stop_music_for_dialogue.connect(stop_all_music_event)
	GameManager.instance.all_states[2].start_music_after_dialogue.connect(restart_music_after_dialogue)

func stop_all_music_event():
	for event: AkEvent3D in get_children():
		#event.stop_event()
		Wwise.post_event("Mu_Stop_All", self)


func restart_music_after_dialogue():
	print("On a set les states")
	Wwise.set_state("Music_State", "Phase4")
	Wwise.set_state("MusicVoicePlaying", "P4_1_Fight")
	#print(get_tree_string_pretty())
	#for event : AkEvent3D in all_events:
		#if event.Post_after_allies==true:
			#event.post_event()
			#print("SAUFDESMOUCHAAAAARDS")
