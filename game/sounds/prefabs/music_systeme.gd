extends Node3D

#@export var all_events : Array[AkEvent3D]

func _ready() -> void:
	#GameManager.instance.all_states[2].stop_music_for_dialogue.connect(stop_all_music_event)
	#GameManager.instance.all_states[3].stop_music_for_ending.connect(stop_all_music_event)
	#GameManager.instance.all_states[2].start_music_after_dialogue.connect(set_diegetic_amount)
	
	#Wwise.set_state("DiegeticAmount", "Diegetic")
	
	
	pass

func set_diegetic_amount():
	#Wwise.set_state("DiegeticAmount", "Extradiegetic")
	#print("On a set les states")
	#Wwise.set_state("Music_State", "Phase4")
	#Wwise.set_state("MusicVoicePlaying", "P4_1_Fight")
	pass
	
	#print(get_tree_string_pretty())
	#for event : AkEvent3D in all_events:
		#if event.Post_after_allies==true:
			#event.post_event()
			#print("SAUFDESMOUCHAAAAARDS")
