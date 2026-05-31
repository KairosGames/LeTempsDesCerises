class_name GameManager extends Node

@onready var player_spawner: CustomMarker = %PlayerSpawner
@onready var pause_container: CenterContainer = %PauseContainer


@export_category("Settings")
@export var use_narrative: bool = true

@export_category("References")
@export var first_barricade: Barricade
@export var canon: Canon

@export_category("Packed Scenes")
@export var player_prefab: PackedScene
@export var all_states: Array[GameState]

var player: Player
var curr_state: GameState
var game_state_index: int = -1

var is_in_pause: bool = false

var pause_twn: Tween

static var active_fight_area: FightArea
static var instance: GameManager:
	set(value):
		if not instance: instance = value
		else: push_error("MORE THAN ONE GAME_MANAGER IN SCENE")


func _ready() -> void:
	instance = self
	pause_container.visible = false
	if canon: canon.shoot.connect(handle_canon_shoot)
	ready_deferred.call_deferred()


func ready_deferred() -> void:
	spawn_player_if_needed()
	set_run()


func _process(_delta: float) -> void:
	handle_pause_menu()


func spawn_player_if_needed() -> void:
	if Player.instance:
		print_rich("[color=yellow]PLAYER ALREADY IN SCENE ![/color]")
		return
	var new_player: Player = player_prefab.instantiate()
	get_parent().add_child(new_player)
	print_rich("[color=yellow]NEW PLAYER HAS SPAWN ![/color]")


func set_run() -> void:
	player = Player.instance
	if use_narrative:
		go_next_state()
		return
	set_player_out_of_run()


func set_player_out_of_run() -> void:
	player.initiate(player_spawner.global_position, player_spawner.global_rotation)
	player.blink_effect.set_eyes_to_step(BlinkEffect.EyesStep.OPEN)


func go_next_state() -> void:
	if curr_state:
		curr_state.completed.disconnect(go_next_state)
		curr_state.exit()
		curr_state.is_active = false
	
	game_state_index += 1
	
	if game_state_index >= all_states.size():
		print("GAME IS FINISHED !")
		return
	
	curr_state = all_states[game_state_index]
	curr_state.completed.connect(go_next_state)
	curr_state.is_active = true
	curr_state.enter()


func handle_pause_menu() -> void:
	if Input.is_action_just_pressed("pause"):
		is_in_pause = not is_in_pause
		pause_container.visible = is_in_pause
		if not player.p_inputs.is_gamepad: Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if is_in_pause else Input.MOUSE_MODE_CAPTURED
		var targ: float = 0.0 if is_in_pause else 1.0
		if pause_twn: pause_twn.kill()
		pause_twn = create_tween()
		pause_twn.set_ignore_time_scale(true)
		pause_twn.tween_property(Engine, "time_scale", targ, 0.37)


func is_game_playing() -> bool:
	return not is_in_pause


func handle_canon_shoot() -> void:
	var curr_barricade = get_active_barricade()
	if curr_barricade: curr_barricade.take_damage()


func get_active_barricade() -> Barricade:
	return first_barricade
