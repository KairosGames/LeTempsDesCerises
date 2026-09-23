class_name CoverGroupTransfer extends Node

@export_category("Activation groups")
@export var cover_group_to_transfer: Array[CoverGroup]


static var instance: CoverGroupTransfer:
	set(value):
		if value == null or not is_instance_valid(instance): instance = value
		else: push_error("MORE THAN ONE COVER_GROUP_TRANSFER IN SCENE")


func _init() -> void:
	instance = self


func _exit_tree() -> void:
	instance = null
