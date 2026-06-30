extends AkEvent3D

@export var Voice_sel: String = "None"
@export var Distance_scale: int = 20
@export var DistScale:WwiseRTPC
@export var IsPlay:WwiseRTPC
@export var Is_playing: float = 0
@export var Enter_at: String = "None"
@export var Post_event: bool = false
@export var Post_after_allies: bool = false
@export var Post_for_ending_choice: bool = false
@export var Is_vocal: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	if GameManager.instance:
		GameManager.instance.all_states[2].start_music_after_dialogue.connect(post_after_allies)
		GameManager.instance.all_states[3].ending_music_choice_scene.connect(post_event_debug)
		GameManager.instance.all_states[2].stop_music_for_dialogue.connect(stop_event_with_signal_for_allies_dialogue)
		GameManager.instance.all_states[3].stop_music_for_choice.connect(stop_event_with_signal_for_ending_choice)
		GameManager.instance.all_states[3].stop_music_for_ending.connect(stop_event_with_signal)
	else:
		printerr("NO GAME MANAGER FOUND AK_MUSICEVENT")
	
	Wwise.set_switch("Voice_Sel", Voice_sel, self)
	DistScale.set_value(self, Distance_scale)
	if Post_event == true:
		post_event()
	IsPlay.set_value(self, Is_playing)

func post_after_allies():
	#print("Func Post after allies")
	if Post_after_allies == true:
		#print("Normalement ça posts")
		Wwise.set_switch("Voice_Sel", Voice_sel, self)
		#Is_playing = 100.0
		#IsPlay.set_value(self, Is_playing)
		post_event()
	pass

func post_event_debug():
	if Post_for_ending_choice == true:
		Wwise.set_state("MusicVoicePlaying","P4_2_End")
		Wwise.set_switch("Voice_Sel", Voice_sel, self)
		post_event()
	pass

func _on_music_sync_user_cue(data: Dictionary) -> void:
	
	if data.has("pszUserCueName"):
		var user_cue_name: String = data["pszUserCueName"]
		
		if user_cue_name == Enter_at: # Rendre changeable dans le préfab
			Is_playing = 100.0
			IsPlay.set_value(self, Is_playing)
			#print("j'ai trouvé : ", user_cue_name)

func stop_event_with_signal():
	stop_event()

func stop_event_with_signal_for_ending_choice():
	Wwise.set_state("BarricadeDestroyed","None")
	stop_event()

func stop_event_with_signal_for_allies_dialogue():
	if Is_vocal == true:
		stop_event()

	
