extends PanelContainer

@export var text_box : VBoxContainer

var allow_credits : bool = false

func _ready() -> void:
	await get_tree().create_timer(1).timeout
	GameManager.instance.all_states[3].game_ended.connect(fade_in)

func _process(delta: float) -> void:
	if allow_credits:
		text_box.position.y += -150 * delta

func start_credits():
	text_box.show()
	await get_tree().create_timer(5).timeout
	allow_credits = true
	await get_tree().create_timer(40).timeout
	self.hide()
	get_tree().quit()

func fade_in():
	self.show()
	var tween = get_tree().create_tween()
	tween.tween_property(text_box, "modulate:a", 1, 3)
	tween.play()
	await tween.finished
	tween.kill()
	start_credits()
