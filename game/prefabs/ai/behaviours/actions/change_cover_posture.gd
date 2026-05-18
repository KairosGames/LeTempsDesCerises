@tool
class_name ChangeCoverPosture extends ActionLeaf

@export var type: Type
@export var duration: float = 2

var _has_started: bool = false
var _is_transitioning: bool = false

func tick(actor: Node, _blackboard: Blackboard) -> int:
	if _has_started:
		if _is_transitioning: return RUNNING
		else: 
			_has_started = false
			return SUCCESS
	else:
		var agent: Agent = actor
		var posture: Agent.Posture
		
		match type:
			Type.SHOOT: posture = agent.cover.get_shoot_posture()
			Type.COVER: posture = agent.cover.get_cover_posture()
			Type.RELOAD: posture = agent.cover.get_reload_posture()
			Type.PEEK: posture = agent.cover.get_shoot_posture()
			
		_is_transitioning = true
		agent.posture_changed.connect(_on_posture_changed.bind(posture))
		
		agent.posture = posture # TODO? set
		
		#get_tree().create_timer(duration).timeout.connect(_on_animation_finished, CONNECT_ONE_SHOT)
		
		return RUNNING

func _on_posture_changed(new: Agent.Posture, final: Agent.Posture) -> void:
	if new == final: _is_transitioning = false

#func _on_animation_finished() -> void:

enum Type { SHOOT, PEEK, COVER, RELOAD }
