extends Node3D


#@export var all_events : Array[AkEvent3D]

func _ready() -> void:
	if GameManager.instance:
		GameManager.instance.all_states[2].stop_music_for_dialogue.connect(stop_instrumental_with_signal)
	else:
		printerr("NO GAME MANAGER FOUND AK_MUSICEVENT")


func stop_instrumental_with_signal():
	Wwise.post_event("Mu_Stop_All",self)
	pass
	
	#print(get_tree_string_pretty())
	#for event : AkEvent3D in all_events:
		#if event.Post_after_allies==true:
			#event.post_event()
			#print("SAUFDESMOUCHAAAAARDS")
