class_name Navigation extends NavigationAgent3D

#signal event(Event)
#
#enum Event { STARTED, REACHED, CANCELED }

@export var movement_speed: float = 4.0

var target: Node3D = null

var _character: CharacterBody3D = null
var _physics_delta: float

func _ready() -> void:
	# path_changed
	#target_reached.connect(_on_target_reached)
	#navigation_finished.connect(_navigation_finished)
	_character = get_parent()
	if not _character: printerr("not child of a CharacterBody3D")
	velocity_computed.connect(_on_velocity_computed)
	max_speed = movement_speed
#
#func _on_target_reached() -> void: event.emit(Event.REACHED)
#func _navigation_finished() -> void: event.emit(Event.CANCELED)

func _physics_process(delta: float) -> void:
	_physics_delta = delta
	
	if not _character: return
	if not NavigationServer3D.map_get_iteration_id(get_navigation_map()): return # map is not initialized.
	
	if target: target_position = target.global_position
	
	if is_navigation_finished(): return
	
	var next_path_position: Vector3 = get_next_path_position()
	if next_path_position != _character.global_position: 
		_character.look_at(next_path_position)
		var dir: Vector3 = _character.global_position.direction_to(next_path_position)
		var new_velocity: Vector3 = dir * movement_speed
		if avoidance_enabled: set_velocity(new_velocity)
		else: _on_velocity_computed(new_velocity)

func _on_velocity_computed(safe_velocity: Vector3) -> void:
	_character.velocity = safe_velocity
	_character.move_and_slide()

func move_to(global_position: Vector3) -> void:
	target = null
	target_position = global_position
	#event.emit(Event.STARTED)

func move_in_range(global_position: Vector3, desired_distance: float) -> void:
	target_desired_distance = desired_distance
	move_to(global_position)

func stop() -> void:
	target_position = _character.global_position
	velocity_computed.emit(Vector3.ZERO)
