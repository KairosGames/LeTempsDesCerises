@tool
class_name ChangeCoverPosture extends ChangePosture

@export var action: Cover.Action

func get_posture(agent: Agent) -> Agent.Posture:
	return agent.cover.get_posture_for(action) if agent.cover else Agent.Posture.STAND

func _validate_property(property: Dictionary) -> void:
	match property.name:
		"posture": property.usage = PROPERTY_USAGE_NO_EDITOR
