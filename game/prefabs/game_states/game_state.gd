@abstract class_name GameState extends Node

@warning_ignore("unused_signal") signal completed
@warning_ignore("unused_signal") signal voice_line_finished

@abstract func enter() -> void
@abstract func exit() -> void

var steps: Array[Step] = []
var curr_step: int = 0

var game_manager: GameManager
var eff_manager: EffectsManager
var player: Player
var on_process: Callable
var delta_t: float


func _ready() -> void:
	ready_deffered.call_deferred()


func ready_deffered() -> void:
	on_process = do_nothing
	game_manager = GameManager.instance
	eff_manager = EffectsManager.instance
	player = Player.instance


func _process(delta: float) -> void:
	delta_t = delta
	on_process.call()
	if Input.is_action_just_pressed("go_next_step"):
		voice_line_finished.emit()


func run_steps() -> void:
	for step in steps:
		await step.on_enter.call()
		await step.is_done.call()
		await step.on_exit.call()
		print("STEP ", curr_step, " PASSED !")
		curr_step += 1
	completed.emit()


func do_nothing(_p: float = 0.0) -> void:
	pass


func wait(seconds: float) -> bool:
	await get_tree().create_timer(seconds).timeout
	return true


func wait_until(condition: Callable) -> void:
	while not condition.call():
		await get_tree().process_frame


func wait_signal(signal_to_wait: Signal) -> void:
	await signal_to_wait


func wait_voice() -> void:
	await voice_line_finished


func set_on_process(callable: Callable) -> void:
	on_process = callable


func clean_process() -> void:
	on_process = do_nothing

func walk_forward(delta: float, speed: float) -> void:
	player.velocity = player.basis.z * speed
	player.move_and_slide()
