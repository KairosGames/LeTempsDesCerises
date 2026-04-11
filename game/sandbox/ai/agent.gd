class_name Agent extends CharacterBody3D

@onready var navigation: Navigation = $Navigation

var is_weapon_loaded: bool = false:
	set(value):
		if is_weapon_loaded and not value: 
			print("Shoot")
			print_stack()
		if not is_weapon_loaded and value:
			print("Reloaded")
			print_stack()
		is_weapon_loaded = value


var cover: Cover = null

var team: Team = Team.VERSALLAIS

enum Team { VERSALLAIS = -1, NONE = 0, COMMUNARD = 1 }

func _ready() -> void:
	$BeehaveTree.name = name
