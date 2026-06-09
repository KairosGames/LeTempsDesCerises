@tool
class_name ChangePosture extends ActionLeaf

@export var posture: Agent.Posture
@export var duration: float = 0.2

var _has_started: bool = false
var _is_transitioning: bool = false
var _timer: Timer 

func get_posture(_agent: Agent) -> Agent.Posture: return posture

func _ready() -> void:
	_timer = Timer.new()
	_timer.autostart = false
	_timer.timeout.connect(_on_animation_finished)
	add_child(_timer)

func tick(actor: Node, _blackboard: Blackboard) -> int:
	var agent: Agent = actor
	if _has_started:
		if _is_transitioning: return RUNNING
		else: 
			_has_started = false
			_on_finished(actor)
			return SUCCESS
	else:
		_has_started = true
		_is_transitioning = true
		var current_posture: Agent.Posture = agent.posture
		var new_posture: Agent.Posture = get_posture(agent)
		if current_posture == new_posture: 
			_on_start(actor)
			_has_started = false
			_is_transitioning = false
			_on_finished(actor)
			return SUCCESS
		else: 
			agent.posture = new_posture
			_on_start(actor)
			_timer.start(duration)
			return RUNNING

func _on_animation_finished() -> void: _is_transitioning = false

func _on_start(_agent: Agent) -> void: pass
func _on_finished(_agent: Agent) -> void: pass
