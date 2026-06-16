class_name FightTask extends Node

func enter_in_fight(npc: Npc) -> void:
	while true:
		if npc.animator.current_animation != "stand-aiming": npc.animator.play("stand-aiming")
		var rnd: float = randf_range(2.5, 3.5)
		await get_tree().create_timer(rnd).timeout
		await npc.shoot()
		npc.animator.play("stand-aiming")
		await get_tree().create_timer(1.0).timeout
		await npc.enter_reload()
		npc.animator.play("stand-aiming")
		rnd = randf_range(3.0, 4.5)
		await get_tree().create_timer(rnd).timeout
		await get_tree().process_frame
