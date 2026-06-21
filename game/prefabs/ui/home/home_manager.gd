class_name HomeManager extends Control

const SCENE = preload("uid://bqw181keq72d")

@onready var references: PanelContainer = %References
@onready var credit: PanelContainer = %Credit
@onready var option: TabContainer = %Option

func _on_play_pressed() -> void:
	get_tree().change_scene_to_packed(SCENE)


func _on_options_pressed() -> void:
	option.show()
	references.hide()
	credit.hide()


func _on_referecences_pressed() -> void:
	references.show()
	option.hide()
	credit.hide()


func _on_credits_pressed() -> void:
	credit.show()
	option.hide()
	references.hide()


func _on_quit_pressed() -> void:
	get_tree().quit()
