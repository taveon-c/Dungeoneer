extends Enemy

func generate_markers(level):
	var hints = []
	var options = []
	for direction in [Vector2(-1, 0), Vector2(0, -1), Vector2(1, 0), Vector2(0, 1)]:
		for step in range(1, info.action["range"] + 1):
			var cell_pos = global_position + direction * step * level.info.TILE_SIZE
			var cell_coords = level.map.local_to_map(cell_pos)
			if level.map.get_cell_atlas_coords(cell_coords) == Vector2i(0, 0) and level.visibility.get_cell_atlas_coords(cell_coords) == Vector2i(-1, -1):
				if cell_pos == level.player.global_position:
					options.append(cell_pos)
				else:
					hints.append(cell_pos)
			else:
				break
	level.markers.set_markers(Color.RED, options, hints)

func choose_action():
	var player_visible = is_player_visible()
	if player_visible:
		last_player_position = player.global_position
	var displacement = abs(player.global_position - global_position)
	var is_in_range = ((displacement.x == 0 and displacement.y <= info.action["range"] * level.info.TILE_SIZE) or (displacement.y == 0 and displacement.x <= info.action["range"] * level.info.TILE_SIZE))
	if player_visible and info.energy >= info.action["cost"] and is_in_range:
		take_action(attack, 1)
	elif info.energy > 0:
		var last_player_cell = level.map.local_to_map(last_player_position)
		var potential_cells = []
		for direction in [Vector2i(-1, 0), Vector2i(0, -1), Vector2i(1, 0), Vector2i(0, 1)]:
			var step = 1
			while step <= info.action["range"] and level.map.get_cell_atlas_coords(last_player_cell + direction * step) == Vector2i(0, 0):
				step += 1
			if step > 1:
				potential_cells.append(last_player_cell + direction * (step-1))
		
		level.set_astar_obstacles(["enemy", "pickup"], self)
		var self_id = map.local_to_map(self.global_position)
		var target_cell = potential_cells[0]
		var path_size = level.astar_grid.get_point_path(self_id, target_cell).size()
		for cell in potential_cells:
			var cell_path_size : int = level.astar_grid.get_point_path(self_id, cell).size()
			if cell_path_size < path_size:
				target_cell = cell
				path_size = cell_path_size
		level.clear_astar_obstacles(["enemy", "pickup"])
		
		take_action(move.bind(["enemy", "pickup"], target_cell), 0.3)
	else:
		emit_signal("end_turn")
