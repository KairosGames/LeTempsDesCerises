class_name EventArea extends Area3D

signal player_entered
signal canon_entered


func _on_body_entered(body: Node3D) -> void:
	if body is Player: player_entered.emit()
	if body.get_parent() and body.get_parent() is Canon: canon_entered.emit()


func is_player_inside() -> bool:
	var bodies: Array[Node3D] = get_overlapping_bodies()
	for body: Node3D in bodies:
		if body is Player: return true
	return false
