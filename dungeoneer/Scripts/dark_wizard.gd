extends Enemy

func generate_markers(level):
	var hints = []
	var options = []
	for x in range(-info.action["range"], info.action["range"] + 1):
		for y in range(-info.action["range"], info.action["range"] + 1):
			var cell_local_pos = Vector2(x, y) * level.info.TILE_SIZE
			var cell_pos = cell_local_pos + global_position
			var cell = Vector2i(x, y) + level.map.local_to_map(global_position)
			if cell_local_pos.length() <= info.action["range"] * level.info.TILE_SIZE and cell_local_pos != Vector2(0, 0) and level.map.get_cell_atlas_coords(cell) == Vector2i(0, 0):
				if level.player.global_position == cell_pos:
					options.append(cell_pos)
				else:
					hints.append(cell_pos)
	level.markers.set_markers(Color.RED, options, hints)

func choose_action():
	if is_player_visible():
		last_player_position = player.global_position
	var distance = global_position.distance_to(player.global_position)
	if info.energy >= info.action["cost"] and distance <= info.action["range"] * level.info.TILE_SIZE:
		take_action(attack, 1)
	elif info.energy >= info.action["cost"] and distance > info.action["range"] * level.info.TILE_SIZE:
		take_action(move.bind(["enemy", "pickup"], map.local_to_map(last_player_position)), 0.3)
	elif info.energy > 0 and distance <= info.action["range"]:
		var direction = global_position.direction_to(last_player_position)
		take_action(move.bind(["enemy", "pickup"], map.local_to_map(global_position - direction * info.action["range"] * level.info.TILE_SIZE)), 0.3)
	else:
		emit_signal("end_turn")
