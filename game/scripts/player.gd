class_name Player extends CharacterBody3D

@onready var mouse_inputs: PlayerInputs = %PlayerInputs
@onready var camera_pivot: Node3D = %CameraPivot
@onready var player_camera: Camera3D = %PlayerCamera


const SPEED = 5.0
const JUMP_VELOCITY = 4.5


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()


func _process(delta: float) -> void:
	process_view(delta)


func process_view(delta: float) -> void:
	rotation.y -=  mouse_inputs.get_view_input().x * delta
	camera_pivot.rotation.x += mouse_inputs.get_view_input().y * delta
