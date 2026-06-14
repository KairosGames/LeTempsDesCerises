class_name CoverGroup extends Node

@export var covers: Array[Cover]

@export_category("Enemies settings")
@export var max_enemies: int = 5
@export var enemies_spawn_cd: float = 1.0

@export_category("Allies settings")
@export var max_allies: int = 5
@export var allies_spawn_cd_: float = 1.0

@export_category("Death Covers")
@export var death_covers: Array[Cover]
@export var death_timer: float = 0.5
@export var death_squared_dist: float = 0.2
