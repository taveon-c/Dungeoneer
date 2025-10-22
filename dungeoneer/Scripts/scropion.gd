extends Enemy

func generate_markers(level):
	var hints = []
	var options = []
	for direction in [Vector2(-1,-1), Vector2(-1, 1), Vector2(1, -1), Vector2(1, 1)]:
		for l in range(1, info.action["range"]+1):
			var cell_pos = global_position + direction * l * level.info.TILE_SIZE
			var cell = level.map.local_to_map(cell_pos)
			if level.map.get_cell_atlas_coords(cell) == Vector2i(0, 0) and level.visibility.get_cell_atlas_coords(cell) == Vector2i(-1, -1):
				if cell_pos == level.player.global_position:
					options.append(cell_pos)
				else:
					hints.append(cell_pos)
			else:
				break
	level.markers.set_markers(Color.RED, options, hints)

func get_target_cells():
	var target_cells = []
	for direction in [Vector2(-1,-1), Vector2(-1, 1), Vector2(1, -1), Vector2(1, 1)]:
		for l in range(1, info.action["range"]+1):
			var cell_pos = global_position + direction * l * level.info.TILE_SIZE
			var cell = level.map.local_to_map(cell_pos)
			if is_cell_open(cell):
				target_cells.append(cell)
			else:
				break

func choose_action():
	if is_player_visible():
		var current_cell = level.map.local_to_map(global_position)
		last_player_position = player.global_position
		var target_cells = get_target_cells()
		if target_cells.size() == 0 and info.energy > 0:
			take_action(move.bind(["enemy", "pickup", "player"], map.local_to_map(last_player_position)), 0.3)
		elif current_cell in target_cells and info.energy > info.action["cost"]:
			take_action(attack, 1.1)
			player.info.max_energy -= info.action["poison"]
			player.info.energy = mini(info.max_energy, info.energy)
		elif info.energy > 0:
			var closest_cell = target_cells[0]
			for cell in target_cells:
				var current_path_size = level.astar_grid.get_id_path(current_cell, closest_cell).size()
				var path_size = level.astar_grid.get_id_path(current_cell, cell).size()
				if path_size < current_path_size:
					closest_cell = cell
			take_action(move.bind(["enemy", "pickup", "player"], map.local_to_map(last_player_position)), 0.3)
		else:
			emit_signal("end_turn")
	elif info.energy > 0:
		take_action(move.bind(["enemy", "pickup", "player"], map.local_to_map(last_player_position)), 0.3)
	else:
		emit_signal("end_turn")
