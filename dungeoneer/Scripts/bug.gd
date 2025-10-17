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

func get_target_cells():
	var player_cell = level.map.local_to_map(player.global_position)
	var target_cells = []
	for direction in [Vector2i(-1, -1), Vector2i(-1, 0), Vector2i(-1, 1), Vector2i(0, -1), Vector2i(0, 1), Vector2i(1, -1), Vector2i(1, 0), Vector2i(1, 1)]:
		for l in range(1, info.action["range"] + 1):
			var cell = player_cell + direction * l
			if is_cell_open(cell):
				target_cells.append(cell)
			else:
				break
	return target_cells

func choose_action():
	if is_player_visible():
		last_player_position = player.global_position
		var player_cell = level.map.local_to_map(level.player.global_position)
		var current_cell = level.map.local_to_map(global_position)
		var target_cells = get_target_cells()
		if target_cells.size() == 0:
			take_action(move.bind(["enemy", "pickup"], player_cell), 0.3)
		elif current_cell in target_cells:
			if info.energy >= info.action["cost"]:
				take_action(attack, 1.3)
			elif info.energy > 0:
				var current_player_distance = global_position.distance_to(player.global_position)
				var target_cell : Vector2i
				for cell in target_cells:
					var displacement = abs(cell - current_cell)
					var player_distance = level.map.map_to_local(cell).distance_to(player.global_position)
					if displacement.x <= 1 and displacement.y <= 1 and player_distance < current_player_distance:
						target_cell = cell
						current_player_distance = player_distance
				if target_cell:
					take_action(move.bind(["enemy", "pickup"], target_cell), 0.3)
				else:
					emit_signal("end_turn")
			else:
				emit_signal("end_turn")
		elif info.energy > 0:
			var closest_cell = target_cells[0]
			var closest_path_length = level.astar_grid.get_id_path(current_cell, closest_cell).size()
			for cell in target_cells:
				var path = level.astar_grid.get_id_path(current_cell, cell)
				var path_length = path.size()
				if path_length > closest_path_length:
					closest_cell = cell
					closest_path_length = path_length
			take_action(move.bind(["enemy", "pickup"], closest_cell), 0.3)
		else:
			emit_signal("end_turn")
	elif info.energy > 0:
		take_action(move.bind(["enemy", "pickup"], level.map.local_to_map(last_player_position)), 0.3)
	else:
		emit_signal("end_turn")
