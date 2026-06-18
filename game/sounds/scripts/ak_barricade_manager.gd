extends Node3D

@export var damaged : AkEvent3D

var life : int

func _ready() -> void:
	if GameManager.instance.curr_barricade == get_parent():
		WwiseGlobal.barricade = self
	get_parent().state_changed.connect(set_wwise_state)

func _on_barricade_damaged() -> void:
	damaged.post_event()

func set_wwise_state():
	life = get_parent().state
	match life:
		2:
			Wwise.set_state("barricade_state", "low")
			print("low")
		3:
			Wwise.set_state("barricade_state", "broken")
			WwiseGlobal.barricade == GameManager.instance.curr_barricade
