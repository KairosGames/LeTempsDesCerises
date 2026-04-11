class_name Agent extends CharacterBody3D

@onready var navigation: Navigation = $Navigation

var is_weapon_loaded: bool = false
var is_covered: bool = false

var team: Team = Team.VERSALLAIS

enum Team { VERSALLAIS = -1, NONE = 0, COMMUNARD = 1 }
