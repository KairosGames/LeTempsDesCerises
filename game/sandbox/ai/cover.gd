class_name Cover extends Marker3D

# TODO sides

func _enter_tree() -> void: CoverManager.register(self)
func _exit_tree() -> void: CoverManager.unregister(self)
