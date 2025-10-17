extends Enemy

func generate_markers(level):
	var hints = []
	var options = []
	for x in range(-info.action["range"], info.action["range"]+1):
		for y in range(-info.action["range"], info.action["range"]+1):
			var cell_offset = Vector2(x, y)
			if not cell_offset == Vector2.ZERO:
				var cell_position = global_position + cell_offset * level.info.TILE_SIZE
				var cell = level.map.local_to_map(cell_position)
				if level.map.get_cell_atlas_coords(cell) == Vector2i(0, 0):
					if level.player.global_position == cell_position:
						options.append(cell_position)
					else:
						hints.append(cell_position)
	level.markers.set_markers(Color.RED, options, hints)

func get_target_cells():
	var player_cell = level.map.local_to_map(player.global_position)
	var target_cells = []
	for x in range(-info.action["range"], info.action["range"]+1):
		for y in range(-info.action["range"], info.action["range"]+1):
			var cell = player_cell + Vector2i(x, y)
			if is_cell_open(cell):
				target_cells.append(cell)
	return target_cells

func choose_action():
	if is_player_visible():
		var is_enemy = false
		for enemy in get_tree().get_nodes_in_group("enemy"):
			if not enemy == self and enemy.is_player_visible():
				is_enemy = true
		var current_cell = level.map.local_to_map(global_position)
		var player_cell = level.map.local_to_map(player.global_position)
		if is_enemy:
			var target_cells = get_target_cells()
			if current_cell in target_cells and info.energy >= info.action["cost"]:
				take_action(attack, 1.6)
				if player.info.armor == 0:
					player.info.max_health -= info.action["drain"]
					player.info.health = mini(player.info.max_health, player.info.health)
			elif info.energy > 0:
				var closest_cell = target_cells[0]
				var closest_path_length = level.astar_grid.get_id_path(current_cell, closest_cell).size()
				for cell in target_cells:
					var path = level.astar_grid.get_id_path(current_cell, cell)
					var path_length = path.size()
					if path_length < closest_path_length:
						closest_cell = cell
						closest_path_length = path_length
				take_action(move.bind(["enemy", "pickup"], closest_cell), 0.3)
			else:
				emit_signal("end_turn")
		else:
			level.set_astar_obstacles(["enemy", "pickup"])
			var current_player_path_size = level.astar_grid.get_id_path(current_cell, player_cell, true).size()
			var target_cell : Vector2i
			for x in range(-1, 2):
				for y in range(-1, 2):
					var cell = current_cell + Vector2i(x, y)
					if level.visibility.get_cell_atlas_coords(cell) == Vector2i(-1, -1) and is_cell_open(cell):
						var player_path_size = level.astar_grid.get_id_path(cell, player_cell).size()
						if player_path_size > current_player_path_size:
							target_cell = cell
							current_player_path_size = player_path_size
			level.clear_astar_obstacles()
			if target_cell:
				take_action(move.bind(["enemy", "item"], target_cell), 0.3)
			else:
				emit_signal("end_turn")
	elif info.energy > 0:
		take_action(move.bind(["enemy", "item"], level.map.local_to_map(last_player_position)), 0.3)
	else:
		emit_signal("end_turn")
