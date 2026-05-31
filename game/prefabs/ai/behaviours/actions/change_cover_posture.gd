@tool
class_name ChangeCoverPosture extends ChangePosture

@export var action: Cover.Action

func get_posture(agent: Agent) -> Agent.Posture:
	return agent.cover.get_posture_for(action) if agent.cover else Agent.Posture.STAND

func _validate_property(property: Dictionary) -> void:
	match property.name:
		"posture": property.usage = PROPERTY_USAGE_NO_EDITOR

# TMP
func _on_start(agent: Agent) -> void:
	pass
	# if not agent.cover: return
	# match action:
	# 	Cover.Action.PEEK: agent.look(-agent.cover.global_basis.z * 10)
	# 	Cover.Action.COVER: agent.look(agent.cover.global_basis.x * 10)
	# 	Cover.Action.RELOAD: agent.look(agent.cover.global_basis.z * 10)
