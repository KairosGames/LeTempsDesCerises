class_name Barricade extends Node3D

signal damaged
signal state_changed
signal just_destroyed

@export_category("References")
@export var full_life_modules: Array[StaticBody3D]
@export var damages_modules_1: Array[StaticBody3D]
@export var damages_modules_2: Array[StaticBody3D]
@export var destroyed_modules: Array[StaticBody3D]

@export_category("Settings")
@export var life_btw_steps: int = 1

var all_modules: Array[Array]
var state: int = 0
var max_state: int = 3
var curr_life: int
var is_destroyed: bool = false


func _ready() -> void:
	curr_life = life_btw_steps
	all_modules[0] = full_life_modules
	all_modules[1] = damages_modules_1
	all_modules[2] = damages_modules_2
	all_modules[3] = destroyed_modules
	set_state()


func set_state() -> void:
	for i in range(max_state + 1):
		var state_modules: Array[StaticBody3D] = all_modules[i]
		for body: StaticBody3D in state_modules:
			if i != state: body.process_mode = Node.PROCESS_MODE_DISABLED
			else: body.process_mode = Node.PROCESS_MODE_INHERIT


func take_damage() -> void:
	if is_destroyed: return
	curr_life -= 1
	damaged.emit()
	if curr_life <= 0:
		go_next_step()


func go_next_step() -> void:
	state += 1
	curr_life = life_btw_steps
	state_changed.emit()
	if state >= max_state:
		is_destroyed = true
		just_destroyed.emit()
	set_state()
