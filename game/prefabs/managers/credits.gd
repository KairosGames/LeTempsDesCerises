extends PanelContainer

@export var text_box : VBoxContainer
@export var home_scene: PackedScene

var allow_credits : bool = false


func _ready() -> void:
	await get_tree().create_timer(1).timeout
	GameManager.instance.all_states[3].game_ended.connect(fade_in)


func _process(delta: float) -> void:
	if allow_credits:
		text_box.position.y += -150 * delta


func start_credits() -> void:
	text_box.show()
	await get_tree().create_timer(5).timeout
	allow_credits = true
	await get_tree().create_timer(51).timeout
	self.hide()
	return_to_home()


func fade_in() -> void:
	self.show()
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(text_box, "modulate:a", 1, 3)
	tween.play()
	await tween.finished
	tween.kill()
	start_credits()


func return_to_home() -> void:
	if GameManager.instance.pause_twn:
		GameManager.instance.pause_twn.kill()
	Engine.time_scale = 1.0
	get_tree().change_scene_to_packed(home_scene)
