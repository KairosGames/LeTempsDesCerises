class_name Step extends RefCounted

var on_enter: Callable
var on_doing: Callable
var on_exit: Callable

enum StepState { NONE, ENTER, DOING, EXIT }
var curr_state: StepState = StepState.NONE

func _init( enter: Callable, done: Callable, exit: Callable) -> void:
	on_enter = enter
	on_doing = done
	on_exit = exit
