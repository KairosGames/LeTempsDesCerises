@tool
extends Node

signal show
signal hide
var is_enabled: bool = false:
	set(value):
		is_enabled = value
		print("CoverGizmo: ", value)
