extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	load_bank()

func load_bank():
	Wwise.load_bank("Sb_Player")
	Wwise.load_bank("Sb_Enemy")
	Wwise.load_bank("Sb_Amb")
