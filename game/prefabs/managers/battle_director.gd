class_name BattleDirector extends Node

@export_category("Covers activation")
@export var all_groups: Array[CoverGroup]

var game_manager: GameManager
var enemies_manager: SpawnManager
var allies_manager: SpawnManager

var curr_group: CoverGroup
var curr_mortal_cover: Array[Cover]
var covers_activation_index: int = -1
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
		all_groups = CoverGroupTransfer.instance.cover_group_to_transfer
	else: printerr("NO COVER GROUP TO TRANSFER, USING COVERS LOCAL REFERENCES")
	for spawn_manager: SpawnManager in get_tree().get_nodes_in_group("SpawnManagers"):
		if spawn_manager.team == Agent.Team.VERSAILLAIS: enemies_manager = spawn_manager
		if spawn_manager.team == Agent.Team.COMMUNARD: allies_manager = spawn_manager
	if not enemies_manager: printerr("ENEMIES SPAWN MANAGER NOT FOUND")
	if not allies_manager: printerr("ALLIES SPAWN MANAGER NOT FOUND")


func _process(delta: float) -> void:
	if death_on_cover_enable and covers_activation_index >= 0:
		apply_death_on_covers(delta)
	
	############ FOR DEBUG
	if Input.is_action_just_pressed("go_next_step") and not game_manager.use_narrative:
		print("NEXT COVERS ACTIVATION FORCED !")
		go_next_covers_activation()


func go_next_covers_activation() -> void:
	covers_activation_index += 1
	if covers_activation_index >= all_groups.size():
		printerr("INCONSISTENCY: ACTIVATION INDEX IN BATTLE DIRECTOR")
		return
	print("ACTIVATED : ", CoverGroupTransfer.instance.cover_group_to_transfer[covers_activation_index].name)
	curr_group = all_groups[covers_activation_index]
	game_manager.max_angle_variations[Agent.Team.COMMUNARD] = curr_group.ally_aim_angle
	game_manager.vagueness_decreases[Agent.Team.COMMUNARD] = curr_group.ally_aim_angle_reducer
	game_manager.max_angle_variations[Agent.Team.VERSAILLAIS] = curr_group.enmy_aim_angle
	game_manager.vagueness_decreases[Agent.Team.VERSAILLAIS] = curr_group.enmy_aim_angle_reducer
	curr_mortal_cover = curr_group.death_covers
	death_on_cover_enable = curr_group.is_auto_death_enable
	enemies_manager.target_entity_count = curr_group.max_enemies
	enemies_manager.cooldown = curr_group.enemies_spawn_cd
	allies_manager.target_entity_count = curr_group.max_allies
	allies_manager.cooldown = curr_group.allies_spawn_cd
	for cover: Cover in curr_group.active_covers:
		cover.enabled = true
	for cover: Cover in curr_group.desactive_covers:
		cover.enabled = false
	


func desactivate_all_covers() -> void:
	for cover_group: CoverGroup in all_groups:
		for cover: Cover in cover_group.active_covers:
			cover.enabled = false
		for cover: Cover in cover_group.desactive_covers:
			cover.enabled = false


func apply_death_on_covers(delta: float) -> void:
	if not curr_mortal_cover: return
	death_timer -= delta
	if death_timer >= 0.0: return
	var possible_covers: Array[Cover]
	for cover: Cover in curr_mortal_cover:
		if not cover.holder or cover.holder is Player: continue
		var agent: Agent = (cover.holder as Agent)
		if is_agent_killable(agent, cover):
			possible_covers.push_back(cover)
	if possible_covers.size() <= 0: return
	var rnd: int = randi_range(0, possible_covers.size() -1)
	last_death_cover = possible_covers[rnd]
	var futur_dead: Agent = possible_covers[rnd].holder as Agent
	futur_dead.die()
	death_timer = curr_group.death_timer


func is_agent_killable(agent: Agent, cover: Cover) -> bool:
	if last_death_cover == cover and curr_mortal_cover.size() > 1: return false
	if cover.global_position.distance_squared_to(agent.global_position) > death_square_dist: return false
	if agent.posture == Agent.Posture.NONE: return false
	if float(agent.posture) / cover.get_cover_posture() < 1.01: return false
	return true
