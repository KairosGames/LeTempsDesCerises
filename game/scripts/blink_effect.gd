class_name BlinkEffect extends ColorRect

@onready var shader: ShaderMaterial = material as ShaderMaterial

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

enum EyesStep { OPEN, A_OPEN, A_CLOSED, CLOSED }
var step_target: EyesStep
var height_target: float
var corners_target: float
var softness_target: float


func open_eyes_from_sleep() -> void:
	set_targets(EyesStep.A_CLOSED)
	create_all_tweens()
	var t1: float = 0.3
	height_twn.tween_property(shader, "shader_parameter/opening", height_target, t1)
	corners_twn.tween_property(shader, "shader_parameter/corner_opening", corners_target, t1)
	await softness_twn.tween_property(shader, "shader_parameter/softness", softness_target, t1).finished
	
	#await get_tree().create_timer(0.1).timeout
	
	set_targets(EyesStep.CLOSED)
	create_all_tweens()
	var t2: float = 0.3
	height_twn.tween_property(shader, "shader_parameter/opening", height_target, t2)
	corners_twn.tween_property(shader, "shader_parameter/corner_opening", corners_target, t2)
	await softness_twn.tween_property(shader, "shader_parameter/softness", softness_target, t2).finished
	
	create_all_tweens()
	set_targets(EyesStep.OPEN)
	var t3: float = 0.3
	height_twn.tween_property(shader, "shader_parameter/opening", height_target, t3)
	corners_twn.tween_property(shader, "shader_parameter/corner_opening", corners_target, t3)
	await softness_twn.tween_property(shader, "shader_parameter/softness", softness_target, t3).finished


func move_eyes(step: EyesStep, time: float) -> void:
	set_targets(step)
	create_all_tweens()
	height_twn.tween_property(shader, "shader_parameter/opening", height_target, time)
	corners_twn.tween_property(shader, "shader_parameter/corner_opening", corners_target, time)
	softness_twn.tween_property(shader, "shader_parameter/softness", softness_target, time)


func set_targets(step: EyesStep) -> void:
	step_target = step
	match step_target:
		EyesStep.OPEN:
			height_target = open_height
			corners_target = open_corners
			softness_target = open_softness
		EyesStep.A_OPEN:
			height_target = a_open_height
			corners_target = a_open_corners
			softness_target = a_open_softness
		EyesStep.A_CLOSED:
			height_target = a_closed_height
			corners_target = a_closed_corners
			softness_target = a_closed_softness
		EyesStep.CLOSED:
			height_target = closed_height
			corners_target = closed_corners
			softness_target = closed_softness


func create_all_tweens() -> void:
	kill_all_tweens()
	height_twn = create_tween()
	corners_twn = create_tween()
	softness_twn = create_tween()


func kill_all_tweens() -> void:
	if height_twn: height_twn.kill()
	if corners_twn: corners_twn.kill()
	if softness_twn: softness_twn.kill()




###############
func _ready() -> void:
	await get_tree().create_timer(0.5).timeout
	open_eyes_from_sleep()
	
var i: int = 0
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("TEST"):
		#return
		var t = 0.25
		match i:
			0:
				move_eyes(EyesStep.A_CLOSED, t)
			1:
				move_eyes(EyesStep.CLOSED, t)
			2:
				move_eyes(EyesStep.OPEN, t)
			3:
				move_eyes(EyesStep.A_OPEN, t)
			4:
				move_eyes(EyesStep.A_CLOSED, t)
			5:
				move_eyes(EyesStep.CLOSED, t)
			6:
				move_eyes(EyesStep.A_CLOSED, t)
			7:
				move_eyes(EyesStep.A_OPEN, t)
			8:
				move_eyes(EyesStep.OPEN, t)
			9:
				move_eyes(EyesStep.CLOSED, t)
		i += 1
		if i >= 10: i = 0
