class_name BattleDirector extends Node

@export_category("Covers activation")
@export var active_covers: Array[CoverGroup]

@export_category("Agent death management")
@export var mortal_covers: Array[CoverGroup]

var game_manager: GameManager
var covers_activation_index: int = -1
var death_management_index: int = -1
var death_timer: float = 0.0
var death_square_dist: float = 0.0
var last_death_cover: Cover
var death_on_cover_enable: bool = false

static var instance: BattleDirector:
	set(value):
		if not instance: instance = value
		else: push_error("MORE THAN ONE BATTLE_DIRECTOR IN SCENE")


func _ready() -> void:
	instance = self
	ready_deffered.call_deferred()


func ready_deffered() -> void:
	game_manager = GameManager.instance
	if CoverGroupTransfer.instance:
		active_covers = CoverGroupTransfer.instance.cover_group_to_transfer
		mortal_covers = CoverGroupTransfer.instance.death_group_to_transfer
	else: printerr("NO COVER GROUP TO TRANSFER, USING COVERS LOCAL REFERENCES")


func _process(delta: float) -> void:
	if death_on_cover_enable and death_management_index >= 0:
		apply_death_on_covers(delta)
	
	#DEBUG
	if Input.is_action_just_pressed("go_next_step") and not game_manager.use_narrative:
		go_next_covers_activation()


func go_next_covers_activation() -> void:
	covers_activation_index += 1
	desactivate_all_covers()
	if covers_activation_index >= active_covers.size():
		printerr("INCONSISTENCY: ACTIVATION INDEX IN BATTLE DIRECTOR")
		return
	for cover: Cover in active_covers[covers_activation_index].covers:
		cover.enabled = true


func desactivate_all_covers() -> void:
	for cover_group: CoverGroup in active_covers:
		for cover: Cover in cover_group.covers:
			cover.enabled = false


func go_next_death_management() -> void:
	death_on_cover_enable = true
	death_management_index += 1
	if death_management_index >= mortal_covers.size():
		printerr("INCONSISTENCY: DEATH INDEX IN BATTLE DIRECTOR")
		return
	death_timer = mortal_covers[death_management_index].death_timer
	death_square_dist = mortal_covers[death_management_index].death_squared_dist


func apply_death_on_covers(delta: float) -> void:
	death_timer -= delta
	if death_timer >= 0.0: return
	var curr_cover_group: CoverGroup = mortal_covers[death_management_index]
	var possible_covers: Array[Cover]
	for cover: Cover in curr_cover_group.covers:
		if not cover.holder or cover.holder is Player: continue
		var agent: Agent = (cover.holder as Agent)
		if is_agent_killable(agent, cover):
			possible_covers.push_back(cover)
	if possible_covers.size() <= 0: return
	var rnd: int = randi_range(0, possible_covers.size() -1)
	last_death_cover = possible_covers[rnd]
	var futur_dead: Agent = possible_covers[rnd].holder as Agent
	futur_dead.die()
	death_timer = mortal_covers[death_management_index].death_timer


func is_agent_killable(agent: Agent, cover: Cover) -> bool:
	if last_death_cover == cover: return false
	if cover.global_position.distance_squared_to(agent.global_position) > death_square_dist: return false
	if agent.posture == Agent.Posture.NONE: return false
	if float(agent.posture) / cover.get_cover_posture() < 1.01: return false
	return true
