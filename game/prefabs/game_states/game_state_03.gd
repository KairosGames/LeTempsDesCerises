class_name GameState03 extends GameState

func enter() -> void:
	curr_step = 0
	steps = [
	]
	run_steps()
	if game_manager.use_debug: set_player_for_debug()


func exit() -> void:
	pass


func set_player_for_debug() -> void:
	pass
