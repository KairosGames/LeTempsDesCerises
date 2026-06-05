class_name BlinkEffect extends ColorRect

@onready var shader: ShaderMaterial = material as ShaderMaterial
@onready var blur_effect: BlurEffect = %BlurEffect

@export_category("Closed")
@export var closed_height: float = -0.2
@export var closed_corners: float = 0.3
@export var closed_softness: float = 0.03

@export_category("Almost closed")
@export var a_closed_height: float = 0.1
@export var a_closed_corners: float = 0.5
@export var a_closed_softness: float = 0.15

@export_category("Almost open")
@export var a_open_height: float = 0.2
@export var a_open_corners: float = 0.7
@export var a_open_softness: float = 0.25

@export_category("Open")
@export var open_height: float = 0.6
@export var open_corners: float = 0.8
@export var open_softness: float = 0.4

var height_twn: Tween
var corners_twn: Tween
var softness_twn: Tween
var blur_twn:Tween

enum EyesStep { OPEN, A_OPEN, A_CLOSED, CLOSED }
var step_target: EyesStep
var height_target: float
var corners_target: float
var softness_target: float
var blur_target: float

var s_opening: String = "shader_parameter/opening"
var s_corners: String = "shader_parameter/corner_opening"
var s_softness: String = "shader_parameter/softness"


func open_eyes_from_sleep() -> void:
	set_targets(EyesStep.A_CLOSED)
	create_all_tweens()
	var t1: float = 1.5
	var trans1: Tween.TransitionType = Tween.TRANS_QUAD
	var ea1: Tween.EaseType = Tween.EASE_OUT
	blur_twn.tween_property(blur_effect.shader, blur_effect.s_blur_size, blur_target, t1).set_trans(trans1).set_ease(ea1)
	height_twn.tween_property(shader, s_opening, height_target, t1).set_trans(trans1).set_ease(ea1)
	corners_twn.tween_property(shader, s_corners, corners_target, t1).set_trans(trans1).set_ease(ea1)
	await softness_twn.tween_property(shader, s_softness, softness_target, t1).set_trans(trans1).set_ease(ea1).finished
	
	await get_tree().create_timer(0.5).timeout
	
	set_targets(EyesStep.CLOSED)
	create_all_tweens()
	var t2: float = 0.2
	var trans2: Tween.TransitionType = Tween.TRANS_QUAD
	var ea2: Tween.EaseType = Tween.EASE_IN
	blur_twn.tween_property(blur_effect.shader, blur_effect.s_blur_size, blur_target, t2).set_trans(trans2).set_ease(ea2)
	height_twn.tween_property(shader, s_opening, height_target, t2).set_trans(trans2).set_ease(ea2)
	corners_twn.tween_property(shader, s_corners, corners_target, t2).set_trans(trans2).set_ease(ea2)
	await softness_twn.tween_property(shader, s_softness, softness_target, t2).set_trans(trans2).set_ease(ea2).finished
	
	await get_tree().create_timer(0.1).timeout
	
	set_targets(EyesStep.A_OPEN)
	create_all_tweens()
	var t3: float = 0.5
	var trans3: Tween.TransitionType = Tween.TRANS_QUAD
	var ea3: Tween.EaseType = Tween.EASE_OUT
	blur_twn.tween_property(blur_effect.shader, blur_effect.s_blur_size, blur_target, t3).set_trans(trans3).set_ease(ea3)
	height_twn.tween_property(shader, s_opening, height_target, t3).set_trans(trans3).set_ease(ea3)
	corners_twn.tween_property(shader, s_corners, corners_target, t3).set_trans(trans3).set_ease(ea3)
	await softness_twn.tween_property(shader, s_softness, softness_target, t3).set_trans(trans3).set_ease(ea3).finished
	
	await get_tree().create_timer(1.0).timeout
	
	set_targets(EyesStep.CLOSED)
	create_all_tweens()
	var t4: float = 0.15
	var trans4: Tween.TransitionType = Tween.TRANS_QUAD
	var ea4: Tween.EaseType = Tween.EASE_OUT
	blur_twn.tween_property(blur_effect.shader, blur_effect.s_blur_size, blur_target, t4).set_trans(trans4).set_ease(ea4)
	height_twn.tween_property(shader, s_opening, height_target, t4).set_trans(trans4).set_ease(ea4)
	corners_twn.tween_property(shader, s_corners, corners_target, t4).set_trans(trans4).set_ease(ea4)
	await softness_twn.tween_property(shader, s_softness, softness_target, t4).set_trans(trans4).set_ease(ea4).finished
	
	create_all_tweens()
	set_targets(EyesStep.OPEN)
	var t5: float = 0.5
	var trans5: Tween.TransitionType = Tween.TRANS_QUAD
	var ea5: Tween.EaseType = Tween.EASE_OUT
	blur_twn.tween_property(blur_effect.shader, blur_effect.s_blur_size, blur_target, t5).set_trans(trans5).set_ease(ea5)
	height_twn.tween_property(shader, s_opening, height_target, t5).set_trans(trans5).set_ease(ea5)
	corners_twn.tween_property(shader, s_corners, corners_target, t5).set_trans(trans5).set_ease(ea5)
	await softness_twn.tween_property(shader, s_softness, softness_target, t5).set_trans(trans5).set_ease(ea5).finished


func move_eyes(step: EyesStep, time: float) -> void:
	set_targets(step)
	create_all_tweens()
	height_twn.tween_property(shader, s_opening, height_target, time)
	corners_twn.tween_property(shader, s_corners, corners_target, time)
	softness_twn.tween_property(shader, s_softness, softness_target, time)
	blur_twn.tween_property(blur_effect.shader, blur_effect.s_blur_size, blur_target, time)


func set_targets(step: EyesStep) -> void:
	step_target = step
	match step_target:
		EyesStep.OPEN:
			height_target = open_height
			corners_target = open_corners
			softness_target = open_softness
			blur_target = blur_effect.open_size
		EyesStep.A_OPEN:
			height_target = a_open_height
			corners_target = a_open_corners
			softness_target = a_open_softness
			blur_target = blur_effect.a_open_size
		EyesStep.A_CLOSED:
			height_target = a_closed_height
			corners_target = a_closed_corners
			softness_target = a_closed_softness
			blur_target = blur_effect.a_closed_size
		EyesStep.CLOSED:
			height_target = closed_height
			corners_target = closed_corners
			softness_target = closed_softness
			blur_target = blur_effect.closed_size


func create_all_tweens() -> void:
	kill_all_tweens()
	height_twn = create_tween()
	corners_twn = create_tween()
	softness_twn = create_tween()
	blur_twn = create_tween()


func kill_all_tweens() -> void:
	if height_twn: height_twn.kill()
	if corners_twn: corners_twn.kill()
	if softness_twn: softness_twn.kill()
	if blur_twn: blur_twn.kill()


func set_eyes_to_step(step: EyesStep) -> void:
	match step:
		EyesStep.OPEN:
			shader.set_shader_parameter("opening", open_height)
			shader.set_shader_parameter("corner_opening", open_corners)
			shader.set_shader_parameter("softness", open_softness)
			blur_effect.shader.set_shader_parameter("blur_size", blur_effect.open_size)
		EyesStep.A_OPEN:
			shader.set_shader_parameter("opening", a_open_height)
			shader.set_shader_parameter("corner_opening", a_open_corners)
			shader.set_shader_parameter("softness", a_open_softness)
			blur_effect.shader.set_shader_parameter("blur_size", blur_effect.a_open_size)
		EyesStep.A_CLOSED:
			shader.set_shader_parameter("opening", a_closed_height)
			shader.set_shader_parameter("corner_opening", a_closed_corners)
			shader.set_shader_parameter("softness", a_closed_softness)
			blur_effect.shader.set_shader_parameter("blur_size", blur_effect.a_closed_size)
		EyesStep.CLOSED:
			shader.set_shader_parameter("opening", closed_height)
			shader.set_shader_parameter("corner_opening", closed_corners)
			shader.set_shader_parameter("softness", closed_softness)
			blur_effect.shader.set_shader_parameter("blur_size", blur_effect.closed_size)
