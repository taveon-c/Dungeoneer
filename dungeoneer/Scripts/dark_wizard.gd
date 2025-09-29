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
	elif info.energy > 0 and distance < info.action["range"] * level.info.TILE_SIZE:
		var current_cell = level.map.local_to_map(global_position)
		for direction in [Vector2i(-1, -1), Vector2i(-1, 0), Vector2i(-1, 1), Vector2i(0, -1), Vector2i(0, 1), Vector2i(1, -1), Vector2i(1, 0), Vector2i(1, 1)]:
			var cell = current_cell + direction
			var cell_position = global_position + direction * level.info.TILE_SIZE
			var cell_distance = cell_position.distance_to(player.global_position)
			if level.map.get_atlas_coords(cell) == Vector2i(0, 0) and cell_distance <= info.action["range"]:
				if cell_distance > distance:
					take_action(move.bind(["enemy", "pickup"], cell), 0.3)
					return
	else:
		emit_signal("end_turn")
