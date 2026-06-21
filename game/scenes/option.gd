class_name Option extends TabContainer

func _input(event: InputEvent) -> void:
	
	if not visible: return
	
	if event.is_action_pressed("choice_surrender"): previous()
	if event.is_action_pressed("choice_fight_to_death"): next()

func previous() -> void:
	current_tab = clampi(current_tab - 1, 1, get_child_count() - 2)

func next() -> void:
	current_tab = clampi(current_tab + 1, 1, get_child_count() - 2)
