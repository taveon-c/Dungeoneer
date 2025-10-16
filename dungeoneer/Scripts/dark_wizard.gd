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

func get_target_cells():
	var target_positions = []
	for x in range(-info.action["range"], info.action["range"] + 1):
		for y in range(-info.action["range"], info.action["range"] + 1):
			var cell_length = Vector2(x, y).length()
			if cell_length <= info.action["range"]:
				var cell_pos = player.global_position + Vector2(x, y) * level.info.TILE_SIZE
				var cell = level.map.local_to_map(cell_pos)
				if level.map.get_cell_atlas_coords(cell) == Vector2i(0, 0):
					target_positions.append(cell)
	return target_positions

func choose_action():
	if is_player_visible():
		last_player_position = player.global_position
		var last_player_cell = level.map.local_to_map(last_player_position)
		var target_cells = get_target_cells()
		if target_cells.size() == 0:
			take_action(move.bind(["enemy", "item"], last_player_cell), 0.3)
		elif last_player_cell in target_cells and info.energy >= info.action["cost"]:
			take_action(attack, 1.3)
		elif info.energy > 0:
			var closest_cell = target_cells[0]
			var current_cell = level.map.local_to_map(global_position)
			var closest_path_length = level.astar_grid.get_id_path(current_cell, closest_cell).size()
			for cell in target_cells:
				var path_length = level.astar_grid.get_id_path(current_cell, cell).size()
				if path_length < closest_path_length:
					closest_cell = cell
			take_action(move.bind(["enemy", "item"], closest_cell), 0.3)
		else:
			emit_signal("end_turn")
	elif info.energy > 0:
		take_action(move.bind(["enemy", "item"], level.map.local_to_map(last_player_position)), 0.3)
	else:
		emit_signal("end_turn")
