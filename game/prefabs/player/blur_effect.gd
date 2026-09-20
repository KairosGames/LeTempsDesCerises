class_name BlurEffect extends Node

@export var closed_size: float = 10.0
@export var a_closed_size: float = 8.0
@export var a_open_size: float = 2.0
@export var open_size: float = 0.0

var compositor_effect: BlurCompositorEffect = BlurCompositorEffect.new()
var twn: Tween
var _cameras: Array[Camera3D] = []
var _previous_compositors: Array[Compositor] = []


func _ready() -> void:
	_cameras.assign([%PlayerCamera, %DeathCamera, %WeaponCamera])
	for camera: Camera3D in _cameras:
		_previous_compositors.append(camera.compositor)
		var compositor: Compositor = Compositor.new()
		var effects: Array[CompositorEffect] = []
		if camera.compositor:
			effects.assign(camera.compositor.compositor_effects)
		effects.append(compositor_effect)
		compositor.compositor_effects = effects
		camera.compositor = compositor


func _exit_tree() -> void:
	compositor_effect.enabled = false
	for index: int in range(_cameras.size()):
		if is_instance_valid(_cameras[index]):
			_cameras[index].compositor = _previous_compositors[index]
	_cameras.clear()
	_previous_compositors.clear()


func set_blur_enable(enable: bool) -> void:
	compositor_effect.enabled = enable


func hard_set_blur(value: float) -> void:
	compositor_effect.blur_size = value


func set_blur(value: float, time: float) -> void:
	if twn: twn.kill()
	twn = create_tween()
	await twn.tween_property(compositor_effect, "blur_size", value, time).finished
