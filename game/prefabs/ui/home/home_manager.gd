class_name HomeManager extends Control

const SCROLL_SPEED: float = 650.0
const MAIN_SCENE_PATH: String = "uid://bqw181keq72d"

@onready var references: PanelContainer = %References
@onready var credit: PanelContainer = %Credit
@onready var option: TabContainer = %Option
@onready var menu: PanelContainer = $Menu

@onready var play: ButtonBehavior = $Menu/Buttons/Play
@onready var options_button: ButtonBehavior = $Menu/Buttons/Options
@onready var references_button: ButtonBehavior = $Menu/Buttons/Referecences
@onready var credits_button: ButtonBehavior = $Menu/Buttons/Credits
@onready var references_scroll: ScrollContainer = references.get_node(^"ScrollContainer")
@onready var credit_scroll: ScrollContainer = credit.get_node(^"ScrollContainer")
@onready var references_quit_button: Button = references.get_node(^"Quit")
@onready var credit_quit_button: Button = credit.get_node(^"Quit")

var is_main_scene_loaded: bool = false

func _ready() -> void:
	play.disabled = true
	ResourceLoader.load_threaded_request(MAIN_SCENE_PATH, "PackedScene")
	options_button.grab_focus()
	references_quit_button.pressed.connect(_close_panel.bind(references_button))
	credit_quit_button.pressed.connect(_close_panel.bind(credits_button))


func _on_play_pressed() -> void:
	if not is_main_scene_loaded: return
	play.disabled = true
	var main_scene: PackedScene = ResourceLoader.load_threaded_get(MAIN_SCENE_PATH) as PackedScene
	get_tree().change_scene_to_packed(main_scene)


func _on_options_pressed() -> void:
	_reload_option_sub_manager(^"GAME", "load_game_settings")
	_reload_option_sub_manager(^"VIDEO", "load_video_settings")
	menu.hide()
	option.show()
	references.hide()
	credit.hide()


func _process(delta: float) -> void:
	_update_main_scene_load_state()
	var scroll_container: ScrollContainer = _get_visible_scroll_container()
	if not scroll_container: return

	var scroll_direction: float = Input.get_axis("ui_up", "ui_down")
	scroll_direction += Input.get_axis("move_forward", "move_back")
	scroll_direction += Input.get_axis("aim_top", "aim_down")
	if is_zero_approx(scroll_direction): return

	var scroll_bar: VScrollBar = scroll_container.get_v_scroll_bar()
	scroll_bar.value = clampf(
		scroll_bar.value + scroll_direction * SCROLL_SPEED * delta,
		scroll_bar.min_value,
		scroll_bar.max_value
	)


func _update_main_scene_load_state() -> void:
	if is_main_scene_loaded: return
	var load_status: ResourceLoader.ThreadLoadStatus = ResourceLoader.load_threaded_get_status(MAIN_SCENE_PATH)
	if load_status == ResourceLoader.THREAD_LOAD_LOADED:
		is_main_scene_loaded = true
		play.disabled = false


func _input(event: InputEvent) -> void:
	if not references.visible and not credit.visible and not option.visible: return
	if event.is_action_pressed("ui_cancel"):
		_close_current_panel()
		get_viewport().set_input_as_handled()


func _on_referecences_pressed() -> void:
	menu.hide()
	references.show()
	option.hide()
	credit.hide()
	references_scroll.grab_focus()


func _on_credits_pressed() -> void:
	menu.hide()
	credit.show()
	option.hide()
	references.hide()
	credit_scroll.grab_focus()


func _on_quit_pressed() -> void:
	get_tree().quit()


func _get_visible_scroll_container() -> ScrollContainer:
	if references.visible: return references_scroll
	if credit.visible: return credit_scroll
	return null


func _close_current_panel() -> void:
	if references.visible:
		_close_panel(references_button)
	elif credit.visible:
		_close_panel(credits_button)
	elif option.visible:
		_close_panel(options_button)


func _close_panel(focus_target: Control) -> void:
	references.hide()
	credit.hide()
	option.hide()
	menu.show()
	focus_target.grab_focus()


func _reload_option_sub_manager(tab_path: NodePath, method_name: String) -> void:
	var sub_manager: Node = option.get_node(tab_path)
	if sub_manager.has_method(method_name):
		sub_manager.call(method_name)
