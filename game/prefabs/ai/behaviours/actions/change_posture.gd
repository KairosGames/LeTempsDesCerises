@tool
class_name ChangePosture extends ActionLeaf

@export var posture: Agent.Posture
@export var duration: float = 0.5

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
	if _has_started:
		if _is_transitioning: return RUNNING
		else: 
			_has_started = false
			return SUCCESS
	else:
		_has_started = true
		_is_transitioning = true
		(actor as Agent).posture = get_posture(actor)
		_timer.start(duration)
		return RUNNING

func _on_animation_finished() -> void: _is_transitioning = false
