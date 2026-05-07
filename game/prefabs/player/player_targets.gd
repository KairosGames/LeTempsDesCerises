class_name PlayerTargets extends Node

@onready var player: Player = get_parent()
@onready var head_target: Marker3D = %HeadTarget
@onready var chest_target: Marker3D = %ChestTarget
@onready var left_shoulder_target: Marker3D = %LeftShoulderTarget
@onready var right_shoulder_target: Marker3D = %RightShoulderTarget
@onready var pelvis_target: Marker3D = %PelvisTarget

@export var editor_marks: Array[Node3D]
@export var are_marks_visibles: bool = false
var head_targ_offset: float
var chest_targ_offset: float
var shoulder_targ_offset: float
var pelvis_targ_offset: float


func _ready() -> void:
	set_editor_marks()
	if not player.is_node_ready(): await player.ready
	var cam_pos_y: float = player.camera_pivot.position.y
	head_targ_offset = head_target.position.y - cam_pos_y
	chest_targ_offset = chest_target.position.y - cam_pos_y
	shoulder_targ_offset = left_shoulder_target.position.y - cam_pos_y
	pelvis_targ_offset = pelvis_target.position.y - cam_pos_y


func _process(_delta: float) -> void:
	var cam_pos_y: float = player.camera_pivot.position.y
	head_target.position.y = cam_pos_y + head_targ_offset
	left_shoulder_target.position.y = cam_pos_y + shoulder_targ_offset
	right_shoulder_target.position.y = cam_pos_y + shoulder_targ_offset
	if player.low_collider.disabled:
		chest_target.position.y = cam_pos_y + chest_targ_offset
		pelvis_target.position.y = cam_pos_y+ pelvis_targ_offset
		chest_target.position.z = 0.0
		pelvis_target.position.z = 0.0
		return
	var caps_height: float = player.low_capsule_shape.height
	var caps_radius: float = player.low_capsule_shape.radius
	chest_target.position.y = cam_pos_y 
	pelvis_target.position.y = cam_pos_y
	chest_target.position.z = caps_radius - caps_height - chest_targ_offset
	pelvis_target.position.z = caps_radius - caps_height - pelvis_targ_offset

func set_editor_marks() -> void:
	for mark: Node3D in editor_marks:
		mark.visible = are_marks_visibles
