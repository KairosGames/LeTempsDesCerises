class_name Agent extends CharacterBody3D

@onready var navigation: Navigation = $Navigation
@onready var animation: AnimationPlayer = $AnimationPlayer

signal shoot
signal reload_start
signal reload_end
signal move_start
signal move_end

var is_weapon_loaded: bool = false

var cover: Cover = null

var team: Team = Team.VERSALLAIS

enum Team { VERSALLAIS = -1, NONE = 0, COMMUNARD = 1 }
