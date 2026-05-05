@tool
class_name SpawnManager extends Node

@export var spawners: Array[Cover]
@export var cooldown: float = 60
@export var target_entity_count: int = 6

const VERSAILLAIS = preload("uid://d28tbnqpob3um")

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

func _ready() -> void:
	if Engine.is_editor_hint(): return
	for spawner: Cover in spawners:
		if spawner: 
			_open_list.push_back(spawner)

func _process(_delta: float) -> void:
	if Engine.is_editor_hint(): return
	_process_spawn()

func _process_spawn():
	if _entity_count < target_entity_count:
		for spawner: Cover in _open_list:
			if not spawner.enabled: continue
			if CoverManager.is_free(spawner) and CoverManager.try_take_cover(spawner):
				_open_list.erase(spawner)
				_close_list.push_back(spawner)
				get_tree().create_timer(cooldown).timeout.connect(_restore.bind(spawner))
				_entity_count += 1
				var versaillais: Agent = VERSAILLAIS.instantiate()
				versaillais.cover = spawner
				versaillais.position = spawner.global_position
				versaillais.died.connect(_on_entity_died)
				add_child(versaillais)
				return

func _on_entity_died() -> void: _entity_count -= 1

func _restore(spawner: Cover) -> void:
	_close_list.erase(spawner)
	_open_list.push_back(spawner)
