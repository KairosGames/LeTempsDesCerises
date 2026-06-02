extends Node3D

@export var dialogue_event : AkEvent3D

var npc_name : String

func init() -> void:
	npc_name = get_parent().name
	print("my name is ", npc_name, " and parent is ", get_parent())
	WwiseGlobal.narrators.append(self)
	Wwise.set_switch("Character", npc_name, dialogue_event)

func voiceline():
	dialogue_event.post_event()


func _on_dialogue_end_of_event(_data: Dictionary) -> void:
	WwiseGlobal.line_ended()
