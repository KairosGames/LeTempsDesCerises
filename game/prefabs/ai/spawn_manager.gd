@tool
class_name SpawnManager extends Node

@export var spawners: Array[Cover]
@export var cooldown: float = 60
@export var target_entity_count: int = 6
@export var team: Agent.Team = Agent.Team.NONE

const VERSAILLAIS: PackedScene = preload("uid://d28tbnqpob3um")
const COMMUNARD: PackedScene  = preload("uid://dydlynqmwu5n5")

var _entity_count: int = 0

var _open_list: Array[Cover] = []
var _close_list: Array[Cover] = []

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray
	for spawner: Cover in spawners:
		if not spawner: continue
		if not spawner.type == Cover.Type.SPAWNER:
			warnings.append("%s is not a Spawner" % spawner.name)
	return warnings

func get_monitor_value() -> int: return _entity_count

func _ready() -> void:
	if Engine.is_editor_hint(): return
	_init_spawner()
	Performance.add_custom_monitor("Gameplay/Entity %s" % Agent.Team.find_key(team), get_monitor_value )

func _process(_delta: float) -> void:
	if Engine.is_editor_hint(): return
	_process_spawn()

func _init_spawner() -> void:
	for spawner: Cover in spawners:
		if spawner: _open_list.push_back(spawner)

func _process_spawn() -> void:
	if team == Agent.Team.NONE: return
	if _entity_count < target_entity_count:
		for spawner: Cover in _open_list:
			if not spawner.enabled: continue
			if spawner.holder: continue
			if team == Agent.Team.COMMUNARD and spawner.visible_on_screen_notifier.is_on_screen(): continue
			if not _has_a_next_cover_available(spawner): continue

			_open_list.erase(spawner)
			_close_list.push_back(spawner)
			get_tree().create_timer(cooldown).timeout.connect(_restore.bind(spawner))
			_entity_count += 1
			var prefab: PackedScene
			match team:
				Agent.Team.VERSAILLAIS: prefab = VERSAILLAIS
				Agent.Team.COMMUNARD: prefab = COMMUNARD
			var agent: Agent = prefab.instantiate()
			agent.cover = spawner
			agent.position = spawner.global_position
			agent.died.connect(_on_entity_died)
			add_child(agent)
			return

func _has_a_next_cover_available(cover: Cover) -> bool:
	for next_cover in cover.next_covers:
		if next_cover.is_cover_available(): return true
	return false

func _on_entity_died() -> void: _entity_count -= 1

func _restore(spawner: Cover) -> void:
	_close_list.erase(spawner)
	_open_list.push_back(spawner)
