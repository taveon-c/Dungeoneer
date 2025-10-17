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
		var player_cell = level.map.local_to_map(player.global_position)
		var current_cell = level.map.local_to_map(global_position)
		var target_cells = get_target_cells()
		if current_cell in target_cells and info.energy >= info.action["cost"]:
			take_action(attack, 1.5)
		elif (target_cells.size() == 0 or not current_cell in target_cells) and info.energy > 0:
			take_action(move.bind(["enemy", "pickup"], player_cell), 0.8)
		else:
			emit_signal("end_turn")
	else:
		emit_signal("end_turn")
