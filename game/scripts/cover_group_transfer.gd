class_name CoverGroupTransfer extends Node

@export_category("Activation groups")
@export var cover_group_to_transfer: Array[CoverGroup]


static var instance: CoverGroupTransfer:
	set(value):
		if not instance: instance = value
		else: push_error("MORE THAN ONE COVER_GROUP_TRANSFER IN SCENE")


func _init() -> void:
	instance = self
