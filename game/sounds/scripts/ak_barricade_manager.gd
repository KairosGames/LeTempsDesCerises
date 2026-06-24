extends Node3D

@export var damaged : AkEvent3D

var life : int

func _ready() -> void:
	var barricade: Barricade = get_parent() as Barricade
	if not barricade:
		return
	if GameManager.instance.curr_barricade == barricade:
		WwiseGlobal.barricade = self
	barricade.state_changed.connect(set_wwise_state)

func _on_barricade_damaged() -> void:
	damaged.post_event()

func set_wwise_state() -> void:
	var barricade: Barricade = get_parent() as Barricade
	if not barricade:
		return
	life = barricade.state
	match life:
		2:
			Wwise.set_state("barricade_state", "low")
			print("low")
			if !WwiseGlobal.is_looping:
				WwiseGlobal.is_looping = true
		3:
			if !WwiseGlobal.is_looping:
				WwiseGlobal.is_looping = true
			Wwise.set_state("barricade_state", "broken")
			WwiseGlobal.barricade = self
