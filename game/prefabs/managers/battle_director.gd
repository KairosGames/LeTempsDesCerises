class_name BattleDirector extends Node

@export_category("Covers activation")
@export var active_covers: Array[CoverGroup]

@export_category("Agent death management")
@export var mortal_covers: Array[CoverGroup]
@export var death_timers: Array[float]

var covers_activation_index: int = -1
var death_management_index: int = -1
var death_timer: float = 0.0
var last_death_cover: Cover
var death_on_cover_enable: bool = false
var is_waiting_to_kill: bool = false

static var instance: BattleDirector:
	set(value):
		if not instance: instance = value
		else: push_error("MORE THAN ONE BATTLE_DIRECTOR IN SCENE")


func _ready() -> void:
	instance = self
	await get_tree().create_timer(120.0).timeout
	print("CA COMMENCE !")
	go_next_death_management()


func _process(delta: float) -> void:
	if death_on_cover_enable and death_management_index >= 0:
		apply_death_on_covers(delta)


func go_next_covers_activation() -> void:
	covers_activation_index += 1
	desactivate_all_covers()
	if covers_activation_index >= active_covers.size():
		printerr("INCONSISTENCY: ACTIVATION INDEX IN BATTLE DIRECTOR")
		return
	for cover: Cover in active_covers[covers_activation_index]:
		cover.enabled = true


func desactivate_all_covers() -> void:
	for cover_group: CoverGroup in active_covers:
		for cover: Cover in cover_group.covers:
			cover.enabled = false


func go_next_death_management() -> void:
	death_on_cover_enable = true
	death_management_index += 1
	if death_timers.size() != mortal_covers.size():
		printerr("INCONSISTENCY: DEATH LIST SIZES IN BATTLE DIRECTOR")
		return
	if death_management_index >= death_timers.size():
		printerr("INCONSISTENCY: DEATH INDEX IN BATTLE DIRECTOR")
		return
	death_timer = death_timers[death_management_index]


func apply_death_on_covers(delta: float) -> void:
	death_timer -= delta
	if death_timer >= 0.0: return
	var curr_cover_group: CoverGroup = mortal_covers[death_management_index]
	var possible_covers: Array[Cover]
	for cover: Cover in curr_cover_group.covers:
		if not cover.holder or cover.holder is Player: continue
		var agent: Agent = (cover.holder as Agent)
		if agent.posture != cover.get_cover_posture():
			possible_covers.push_back(cover)
	if possible_covers.size() <= 0: return
	var rnd: int = randi_range(0, possible_covers.size() -1)
	var futur_dead: Agent = possible_covers[rnd].holder as Agent
	futur_dead.die()
	death_timer = death_timers[death_management_index]
