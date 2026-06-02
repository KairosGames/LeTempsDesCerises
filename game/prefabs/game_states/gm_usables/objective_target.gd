class_name ObjectiveTarget extends TextureRect

@export var controller_node: Node3D
@export var camera_node: Camera3D
@export var target: Node3D:
	set(new_value):
		target = new_value
		if target == null: self.hide()
		else: self.show()

@export var rotation_offset_degrees: float = 0.0
@export var border_margin: float = 20.0

var viewport_center: Vector2
var child : TextureRect

func _ready() -> void:
	get_viewport().size_changed.connect(_viewport_size_changed)
	_update_viewport_size()

func _viewport_size_changed():
	_update_viewport_size()

func _update_viewport_size():
	var viewport_rect: Rect2 = get_viewport().get_visible_rect()
	viewport_center = (viewport_rect.position + viewport_rect.size * 0.5)

func _process(_delta: float) -> void:
	if target == null: return
	if not target.is_inside_tree(): return
	
	if camera_node == null:
		camera_node = get_viewport().get_camera_3d()
	if camera_node == null:
		push_warning("Pas de caméra trouvée ; Flèche désactivée.")
		hide()
		return
	
	if camera_node.is_position_in_frustum(target.global_position):
		position = camera_node.unproject_position(target.global_position)
		show()
	else:
		var local_to_camera: Vector3 = camera_node.to_local(target.global_position)
		var reticle_position: Vector2 = Vector2(local_to_camera.x, -local_to_camera.y)
		var limit = Vector2(viewport_center.x - border_margin, viewport_center.y - border_margin)
		var dir2d: Vector2 = reticle_position.normalized()
		var factor: float = min(limit.x / abs(dir2d.x), limit.y / abs(dir2d.y))
		var final_pos: Vector2 = viewport_center + dir2d * factor
		
		position = final_pos - size * 0.5
		rotation = Vector2.UP.angle_to(reticle_position) + deg_to_rad(rotation_offset_degrees)
		show()
