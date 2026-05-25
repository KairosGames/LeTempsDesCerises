class_name Step extends RefCounted

var on_enter: Callable
var is_done: Callable
var on_exit: Callable

func _init( enter: Callable, done: Callable, exit: Callable) -> void:
	on_enter = enter
	is_done = done
	on_exit = exit
