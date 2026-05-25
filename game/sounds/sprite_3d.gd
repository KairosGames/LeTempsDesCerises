extends Sprite3D

var is_pouf : bool = false
var is_pouf2 : bool = false
var nope : bool = true

func pouf():
	rotation.y += randf_range(-45, 45)
	await get_tree().create_timer(1.5).timeout
	show()
	is_pouf = true
 
func pouf2():
	rotation.y += randf_range(-180, 180)
	await get_tree().create_timer(1.5).timeout
	show()
	is_pouf2 = true

func _process(delta: float) -> void:
	if is_pouf and scale.x <= 0.25:
		scale += Vector3(0.0002, 0.0002, 0)
	if is_pouf2 and scale.y <= 0.5:
		scale += Vector3(0.0001, 0.0002, 0)
	if scale.x > 0.1 and nope == true:
		var flower = preload("res://sounds/flower01.fbx")
		flower = flower.instantiate()
		flower.position.x += 0.2
		flower.rotation.x = 90
		flower.scale = Vector3(5, 5, 5)
		add_child(flower)
		nope = false
