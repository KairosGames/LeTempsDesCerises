class_name HomeManager extends Control

@onready var references: PanelContainer = %References
@onready var credit: PanelContainer = %Credit
@onready var option: TabContainer = %Option
@onready var menu: PanelContainer = $Menu

@onready var play: ButtonBehavior = $Menu/Buttons/Play

func _ready() -> void:
	play.grab_focus()

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("uid://bqw181keq72d")


func _on_options_pressed() -> void:
	menu.hide()
	option.show()
	references.hide()
	credit.hide()


func _on_referecences_pressed() -> void:
	menu.hide()
	references.show()
	option.hide()
	credit.hide()


func _on_credits_pressed() -> void:
	menu.hide()
	credit.show()
	option.hide()
	references.hide()


func _on_quit_pressed() -> void:
	get_tree().quit()
