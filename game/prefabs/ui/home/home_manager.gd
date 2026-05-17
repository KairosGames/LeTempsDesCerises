class_name HomeManager extends Control

@export var main_scene: PackedScene


func _on_play_pressed() -> void:
	get_tree().change_scene_to_packed(main_scene)


func _on_options_pressed() -> void:
	pass


func _on_referecences_pressed() -> void:
	pass


func _on_credits_pressed() -> void:
	pass


func _on_quit_pressed() -> void:
	get_tree().quit()
