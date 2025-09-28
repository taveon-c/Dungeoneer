extends Enemy

func generate_hints():
	for x in range(-info.action["range"], info.action["range"] + 1):
		for y in range(-info.action["range"], info.action["range"] + 1):
			var cell_position = Vector2(x, y) * level.info.TILE_SIZE
			if cell_position.length() <= info.action["range"] * level.info.TILE_SIZE:
				level.hints.generate_hint(Color.RED, global_position + cell_position)

func choose_action():
	if is_player_visible():
		last_player_position = player.global_position
	var distance = global_position.distance_to(player.global_position)
	if info.energy >= info.action["cost"] and distance <= info.action["range"] * level.info.TILE_SIZE:
		take_action(attack, 1)
	elif info.energy > 0 and distance > info.action["range"] * level.info.TILE_SIZE:
		take_action(move.bind(["enemy", "pickup"], map.local_to_map(last_player_position)), 0.3)
	else:
		emit_signal("end_turn")
