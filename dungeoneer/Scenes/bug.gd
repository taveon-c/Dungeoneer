extends Enemy

func generate_markers(level):
	var hints = []
	var options = []
	for direction in [Vector2(-1, -1), Vector2(-1, 0), Vector2(-1, 1), Vector2(0, -1), Vector2(0, 1), Vector2(1, -1), Vector2(1, 0), Vector2(1, 1)]:
		for l in range(1, info.action["range"] + 1):
			var cell_position = global_position + direction * l * level.info.TILE_SIZE
			var cell = level.map.local_to_map(cell_position)
			if level.map.get_cell_atlas_coords(cell) == Vector2i(0, 0):
				if level.player.global_position == cell_position:
					options.append(cell_position)
				else:
					hints.append(cell_position)
			else:
				break
	level.markers.set_markers(Color.RED, options, hints)

func choose_action():
	if is_player_visible():
		last_player_position = player.global_position
		var closest_path = []
		var closest_position : Vector2
		var attack_positions : Array[Vector2]
		for direction in [Vector2(-1, -1), Vector2(-1, 0), Vector2(-1, 1), Vector2(0, -1), Vector2(0, 1), Vector2(1, -1), Vector2(1, 0), Vector2(1, 1)]:
			for l in range(1, info.action["range"]+1):
				var target_position = player.global_position + direction * l * level.info.TILE_SIZE
				attack_positions.append(target_position)
				var path = get_grid_path(["enemy", "pickup"], level.map.local_to_map(target_position), false)
				if path.size() < closest_path.size() or closest_path.size() == 0:
					closest_path = path
					closest_position = target_position
		if global_position in attack_positions and info.action["cost"] <= info.energy:
			print("attack")
			take_action(attack, 1.1)
		elif info.energy > 0 and not global_position in attack_positions:
			take_action(move.bind(["enemy", "pickup", "player"], map.local_to_map(closest_position)), 0.7)
		else:
			emit_signal("end_turn")
	elif info.energy > 0:
		take_action(move.bind(["enemy", "pickup", "player"], map.local_to_map(last_player_position)), 0.7)
	else:
		emit_signal("end_turn")
