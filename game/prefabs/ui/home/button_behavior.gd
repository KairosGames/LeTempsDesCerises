class_name ButtonBehavior extends Button

@export var hover_multiplier: float = 1.15
@export var button_type: Type = Type.SIZE

enum Type {SCALE, SIZE}

var start: Vector2


func _ready() -> void:
	await get_tree().process_frame
	start = size if button_type == Type.SIZE else scale
	pivot_offset_ratio = Vector2.ONE * 0.5

func _process(delta: float) -> void:
	var to_mod: String = "custom_minimum_size" if button_type == Type.SIZE else "scale"
	var target: Vector2 = start * hover_multiplier if is_hovered() else start
	set(to_mod, get(to_mod).lerp(target, Tools.dt_lerp(20.0, delta)))
