class_name Barricade extends Node3D

signal damaged
signal state_changed
signal just_destroyed

@export_category("States")
@export var full_life_modules: Node3D
@export var damages_modules_1: Node3D
@export var damages_modules_2: Node3D
@export var destroyed_modules: Node3D

@export_category("Covers")
@export var near_covers: Array[Cover]

@export_category("Settings")
@export var life_btw_steps: int = 1

@onready var all_steps: Array[Node3D] = [full_life_modules, damages_modules_1, damages_modules_2, destroyed_modules]
var state: int = 0
var max_state: int = 3
var curr_life: int
var is_destroyed: bool = false


func _ready() -> void:
	curr_life = life_btw_steps
	set_state()


func set_state() -> void:
	for i in range(all_steps.size()):
		all_steps[i].visible = i == state
		var mode: Node.ProcessMode = PROCESS_MODE_INHERIT if i == state else PROCESS_MODE_DISABLED
		all_steps[i].process_mode = mode


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
	#play vfx destruction
	set_state()
	await get_tree().create_timer(0.1).timeout
	kill_all_near_covers_agents()


func kill_all_near_covers_agents() -> void:
	for cover: Cover in near_covers:
		if cover.holder is Agent: (cover.holder as Agent).die()
