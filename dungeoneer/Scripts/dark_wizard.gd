extends Enemy

func generate_hints():
	for x in range(-info.action["range"], info.action["range"] + 1):
		for y in range(-info.action["range"], info.action["range"] + 1):
			var cell_position = Vector2(x, y) * level.info.TILE_SIZE
			if cell_position.length() <= info.action["range"] * level.info.TILE_SIZE:
				level.hints.generate_hint(Color.RED, global_position + cell_position)

func choose_action():
	var distance = global_position.distance_to(player.global_position)
	if info.energy >= info.action["cost"] and distance <= info.action["range"] * level.info.TILE_SIZE:
		take_action(attack, 1)
	elif info.energy >= info.weight and distance > info.action["range"] * level.info.TILE_SIZE:
		take_action(move.bind(2, ["enemy", "pickup"]), 0.3)
	else:
		emit_signal("end_turn")
