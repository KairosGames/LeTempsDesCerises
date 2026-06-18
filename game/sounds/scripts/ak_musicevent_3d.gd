extends AkEvent3D

@export var Voice_sel: String = "None"
@export var Distance_scale: int = 20
@export var DistScale:WwiseRTPC
@export var IsPlay:WwiseRTPC
var Is_playing: float = 0
@export var Enter_at: String = "None"
@export var Post_event: bool = false
@export var Post_after_allies: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Wwise.set_switch("Voice_Sel", Voice_sel, self)
	DistScale.set_value(self, Distance_scale)
	if Post_event == true:
		post_event()
	# Wwise.set_state("Music_State", "Phase1")
	# IsPlay.set_value(self, Is_playing)



func _on_music_sync_user_cue(data: Dictionary) -> void:
	
	if data.has("pszUserCueName"):
		var user_cue_name: String = data["pszUserCueName"]
		
		if user_cue_name == Enter_at: # Rendre changeable dans le préfab
			#Is_playing = 100.0
			#IsPlay.set_value(self, Is_playing)
			
			#print("j'ai trouvé : ", user_cue_name)
			pass
			
