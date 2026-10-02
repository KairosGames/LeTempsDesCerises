class_name HomeManager extends Control

const SCROLL_SPEED: float = 650.0
const MAIN_SCENE_PATH: String = "uid://bqw181keq72d"

@onready var references: PanelContainer = %References
@onready var credit: PanelContainer = %Credit
@onready var option: Control = %Option
@onready var black_screen: ColorRect = %BlackScreen
@onready var menu: PanelContainer = $Menu

@onready var play_button: ButtonBehavior = menu.get_node(^"Buttons/Play")
@onready var options_button: ButtonBehavior = menu.get_node(^"Buttons/Options")
@onready var references_button: ButtonBehavior = menu.get_node(^"Buttons/Referecences")
@onready var credits_button: ButtonBehavior = menu.get_node(^"Buttons/Credits")
@onready var references_scroll: ScrollContainer = references.get_node(^"ScrollContainer")
@onready var credit_scroll: ScrollContainer = credit.get_node(^"ScrollContainer")
@onready var references_quit_button: Button = references.get_node(^"Quit")
@onready var credit_quit_button: Button = credit.get_node(^"Quit")

var black_screen_twn: Tween
var _main_scene: PackedScene = null

func _ready() -> void:
	_load_game()
	open_home()


func _process(delta: float) -> void:
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

func open_home() -> void:
	fade_black_sceen(2.0, true)


func close_home() -> void:
	black_screen.mouse_filter = Control.MOUSE_FILTER_STOP
	await fade_black_sceen(0.38, false)
	await get_tree().create_timer(1.5).timeout
	play_button.disabled = true
	var main_scene: PackedScene = ResourceLoader.load_threaded_get(MAIN_SCENE_PATH) as PackedScene
	get_tree().change_scene_to_packed(main_scene)


func fade_black_sceen(time: float, fade_out: bool) -> void:
	var targ: float = 0.0 if fade_out else 1.0
	if black_screen_twn: black_screen_twn.kill()
	black_screen_twn = create_tween()
	await black_screen_twn.tween_property(black_screen, "color:a", targ, time).finished

func _on_play_pressed() -> void:
	play_button.disabled = true
	while not _main_scene: await get_tree().process_frame
	get_tree().change_scene_to_packed(_main_scene)


func _on_options_pressed() -> void: _go_to(option)


func _on_referecences_pressed() -> void: _go_to(references)


func _on_credits_pressed() -> void: _go_to(credit)


func _on_quit_pressed() -> void: get_tree().quit()


func _go_to(section: Control) -> void:
	Wwise.post_event("Open", self)
	Wwise.post_event("Clic", self)
	menu.hide()
	section.show()
	section.hidden.connect(menu.show, CONNECT_ONE_SHOT)


func _load_game() -> void:
	ResourceLoader.load_threaded_request(MAIN_SCENE_PATH, "PackedScene")

	var load_status: ResourceLoader.ThreadLoadStatus = ResourceLoader.load_threaded_get_status(MAIN_SCENE_PATH)
	while is_inside_tree() and load_status == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
		await get_tree().process_frame
		load_status = ResourceLoader.load_threaded_get_status(MAIN_SCENE_PATH)

	match load_status:
		ResourceLoader.ThreadLoadStatus.THREAD_LOAD_FAILED:
			push_error("Failed to load the main scene")
		ResourceLoader.ThreadLoadStatus.THREAD_LOAD_INVALID_RESOURCE:
			push_error("Failed to load the main scene: invalid resource")
		ResourceLoader.ThreadLoadStatus.THREAD_LOAD_IN_PROGRESS:
			push_error("Failed to load the main scene: still in progress")
		ResourceLoader.ThreadLoadStatus.THREAD_LOAD_LOADED:
			_main_scene = ResourceLoader.load_threaded_get(MAIN_SCENE_PATH)


func _get_visible_scroll_container() -> ScrollContainer:
	if references.visible: return references_scroll
	if credit.visible: return credit_scroll
	return null
