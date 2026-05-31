class_name UIManager extends Control

@onready var tooltip: Tooltip = %Tooltip
@onready var pause_container: PanelContainer = %PauseContainer
@onready var tutorial_km: PanelContainer = %TutorialKeyboardMouse
@onready var tutorial_gpad: PanelContainer = %TutorialGamepad
@onready var options: ButtonBehavior = %Options

var player: Player

static var instance: UIManager:
	set(value):
		if not instance: instance = value
		else: push_error("MORE THAN ONE GAME_MANAGER IN SCENE")


func _ready() -> void:
	instance = self
	tooltip.visible = false
	pause_container.visible = false
	ready_deferred.call_deferred()


func ready_deferred() -> void:
	player = Player.instance


func handle_tutorial_display() -> void:
	tutorial_gpad.visible = player.p_inputs.is_gamepad
	tutorial_km.visible = not player.p_inputs.is_gamepad


func enter_pause(is_pause: bool) -> void:
	pause_container.visible = is_pause
	if player.p_inputs.is_gamepad: options.grab_focus()
	else: Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if is_pause else Input.MOUSE_MODE_CAPTURED
