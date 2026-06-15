class_name ChoiceTooltip extends HBoxContainer

@onready var francois_label: RichTextLabel = %FrancoisLabel
@onready var louise_label: RichTextLabel = %LouiseLabel

var start: String = "PRESS [color=#f9ee00]"
var francois_end: String = "[/color] TO [color=#ffaf77]SURRENDER[/color]"
var louise_end: String = "[/color] TO [color=#ffaf77]FIGHT TO THE DEATH[/color]"


func _ready() -> void:
	visible = false


func set_labels(is_gpad: bool) -> void:
	var francois_input: String = "L1" if is_gpad else "A"
	var louise_input: String = "R1" if is_gpad else "E"
	francois_label.text = start + francois_input + francois_end
	louise_label.text = start + louise_input + louise_end
