extends Node3D

@export var dialogue_event : AkEvent3D

var npc_name : String

func _enter_tree() -> void:
	npc_name = get_parent().name
	print("my name is ", npc_name)
	WwiseGlobal.narrators.append(self)
	Wwise.set_switch("Character", npc_name, self)

func voiceline():
	dialogue_event.post_event()


func _on_dialogue_end_of_event(_data: Dictionary) -> void:
	WwiseGlobal.line_ended()
