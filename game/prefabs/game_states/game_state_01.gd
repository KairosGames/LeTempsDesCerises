class_name GameState01 extends GameState

@onready var go_to_barricade_2: EventArea = %GoToBarricade2
@onready var return_to_barricade: EventArea = %ReturnToBarricade


func enter() -> void:
	curr_step = 0
	steps = [
		Step.new(do_nothing, do_nothing, do_nothing),
		Step.new(do_nothing, do_nothing, do_nothing),
		Step.new(do_nothing, do_nothing, do_nothing),
	]
	run_steps()


func exit() -> void:
	pass
